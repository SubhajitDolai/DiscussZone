create index idx_profiles_email on public.profiles (email);
create index idx_profiles_user_type on public.profiles (user_type);
create index idx_profiles_role on public.profiles (role);

create index idx_rooms_is_active on public.rooms (is_active);
create index idx_rooms_name on public.rooms (name);

create index idx_room_slots_room_id on public.room_slots (room_id);
create index idx_room_slots_is_active on public.room_slots (is_active);
create index idx_room_slots_time_range on public.room_slots (start_time, end_time);
create index idx_room_slots_allowed_user_type on public.room_slots (allowed_user_type);
create index idx_room_slots_room_active on public.room_slots (room_id, is_active);

create index idx_room_bookings_room_id on public.room_bookings (room_id);
create index idx_room_bookings_slot_id on public.room_bookings (slot_id);
create index idx_room_bookings_organizer_id on public.room_bookings (organizer_id);
create index idx_room_bookings_booking_date on public.room_bookings (booking_date);
create index idx_room_bookings_status on public.room_bookings (status);
create index idx_room_bookings_date_status on public.room_bookings (booking_date, status);

create unique index idx_unique_active_booking 
  on public.room_bookings (room_id, slot_id, booking_date) 
  where (status = 'booked');

create index idx_room_booking_participants_booking_id on public.room_booking_participants (booking_id);
create index idx_room_booking_participants_participant_id on public.room_booking_participants (participant_id);
create index idx_room_booking_participants_status on public.room_booking_participants (status);
create index idx_room_booking_participants_organizer on public.room_booking_participants (booking_id, is_organizer);
create index idx_room_booking_participants_active on public.room_booking_participants (participant_id, status) where (removed_at is null);

create index idx_room_bookings_history_original_booking_id on public.room_bookings_history (original_booking_id);
create index idx_room_bookings_history_room_id on public.room_bookings_history (room_id);
create index idx_room_bookings_history_organizer_id on public.room_bookings_history (organizer_id);
create index idx_room_bookings_history_booking_date on public.room_bookings_history (booking_date);
create index idx_room_bookings_history_archived_at on public.room_bookings_history (archived_at);

create index idx_rbp_history_original_id on public.room_booking_participants_history (original_participant_id);
create index idx_rbp_history_booking_id on public.room_booking_participants_history (booking_id);
create index idx_rbp_history_participant_id on public.room_booking_participants_history (participant_id);
create index idx_rbp_history_archived_at on public.room_booking_participants_history (archived_at);
