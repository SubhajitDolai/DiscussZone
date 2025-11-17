'use client'

import { useState, useCallback } from "react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Loader } from "lucide-react"
import { completeOnboarding } from '../actions'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { useGlobalLoadingBar } from "@/components/providers/LoadingBarProvider"

export function OnboardingForm({ className, ...props }: React.ComponentPropsWithoutRef<"form">) {
  const [isLoading, setIsLoading] = useState(false)
  const [userType, setUserType] = useState<'' | 'student' | 'faculty'>('')
  const router = useRouter()
  const { start, finish } = useGlobalLoadingBar()

  const handleSubmit = useCallback(async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)
    start()

    const formData = new FormData(e.currentTarget)
    const res = await completeOnboarding(formData)

    if (res.error) {
      toast.error(res.error)
      setIsLoading(false)
      finish()
      return
    }

    toast.success('Profile completed successfully')
    router.push('/')
    setIsLoading(false)
  }, [router, start, finish])

  return (
    <form onSubmit={handleSubmit} className={cn("flex flex-col gap-6", className)} {...props}>
      <div className="flex flex-col items-center gap-2 text-center">
        <h1 className="text-2xl font-bold">Complete Your Profile</h1>
        <p className="text-sm text-muted-foreground">
          Please provide your information to access Discusszone
        </p>
      </div>

      <div className="grid gap-6">
        {/* First Name */}
        <div className="grid gap-2">
          <Label htmlFor="first_name">First Name *</Label>
          <Input
            id="first_name"
            name="first_name"
            placeholder="Enter your first name"
            required
          />
        </div>

        {/* Last Name */}
        <div className="grid gap-2">
          <Label htmlFor="last_name">Last Name *</Label>
          <Input
            id="last_name"
            name="last_name"
            placeholder="Enter your last name"
            required
          />
        </div>

        {/* User Type */}
        <div className="grid gap-2">
          <Label htmlFor="user_type">User Type *</Label>
          <Select 
            value={userType}
            onValueChange={(value) => setUserType(value as 'student' | 'faculty')}
            required
          >
            <SelectTrigger>
              <SelectValue placeholder="Select user type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="student">Student</SelectItem>
              <SelectItem value="faculty">Faculty</SelectItem>
            </SelectContent>
          </Select>
          {/* Hidden input for form submission */}
          <input type="hidden" name="user_type" value={userType} />
        </div>

        {/* PRN (Personal Registration Number) */}
        <div className="grid gap-2">
          <Label htmlFor="prn">
            {userType === 'faculty' ? 'Faculty ID *' : 'PRN *'}
          </Label>
          <Input
            id="prn"
            name="prn"
            placeholder={userType === 'faculty' ? 'Enter your faculty ID' : 'e.g. 1132231374'}
            required
          />
        </div>

        {/* Phone Number */}
        <div className="grid gap-2">
          <Label htmlFor="phone_number">Phone Number *</Label>
          <Input
            id="phone_number"
            name="phone_number"
            type="tel"
            placeholder="+91 9145762234"
            required
          />
        </div>

        {/* Course */}
        <div className="grid gap-2">
          <Label htmlFor="course">
            {userType === 'faculty' ? 'Department *' : 'Course *'}
          </Label>
          <Input
            id="course"
            name="course"
            placeholder={userType === 'faculty' ? 'e.g. IT Department' : 'e.g. B.Tech CSE'}
            required
          />
        </div>

        {/* Gender */}
        <div className="grid gap-2">
          <Label htmlFor="gender">Gender</Label>
          <Select name="gender">
            <SelectTrigger>
              <SelectValue placeholder="Select gender" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="male">Male</SelectItem>
              <SelectItem value="female">Female</SelectItem>
              <SelectItem value="other">Other</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Submit */}
        <Button type="submit" className="w-full" disabled={isLoading}>
          {isLoading ? (
            <>
              <Loader className="h-4 w-4 animate-spin" />
              Completing Profile...
            </>
          ) : (
            'Complete Profile'
          )}
        </Button>
      </div>
    </form>
  )
} 