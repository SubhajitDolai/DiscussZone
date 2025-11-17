'use server'

import { createClient } from '@/utils/supabase/server'

export async function completeOnboarding(formData: FormData) {
  const supabase = await createClient()

  // Get current user
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    return { error: 'User not authenticated' }
  }

  // Get form data
  const first_name = formData.get('first_name') as string
  const last_name = formData.get('last_name') as string
  const prn = formData.get('prn') as string
  const phone_number = formData.get('phone_number') as string
  const course = formData.get('course') as string
  const gender = formData.get('gender') as string
  const user_type = formData.get('user_type') as string

  // Validate required fields
  if (!first_name || !last_name || !prn || !phone_number || !course || !user_type) {
    return { error: 'Please fill in all required fields' }
  }

  // Check if PRN already exists
  const { data: existingUser } = await supabase
    .from('profiles')
    .select('prn')
    .eq('prn', prn)
    .neq('id', user.id)
    .single()

  if (existingUser) {
    return { error: 'PRN already exists' }
  }

  // Check if profile already exists
  const { data: existingProfile } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', user.id)
    .single()

  // Prepare profile data according to schema
  const profileData = {
    first_name,
    last_name,
    prn,
    email: user.email || '',
    course,
    gender: gender || null,
    phone_number,
    user_type: user_type as 'student' | 'faculty'
  }

  if (existingProfile) {
    // Update existing profile
    const { error } = await supabase
      .from('profiles')
      .update(profileData)
      .eq('id', user.id)

    if (error) {
      console.error('Profile update error:', error)
      return { error: 'Failed to update profile. Please try again.' }
    }
  } else {
    // Insert new profile (role defaults to 'user' in schema)
    const { error } = await supabase
      .from('profiles')
      .insert({
        ...profileData,
        id: user.id
      })

    if (error) {
      console.error('Profile insert error:', error)
      return { error: 'Failed to create profile. Please try again.' }
    }
  }

  return { success: true }
} 