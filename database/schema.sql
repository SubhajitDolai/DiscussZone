create type user_type as enum ('student', 'faculty');
create type user_role as enum ('user', 'admin', 'super_admin');

create table public.profiles (
  id uuid not null,
  first_name text null,
  last_name text null,
  prn text null,
  email text null,
  course text null,
  gender text null,
  phone_number text null,
  user_type user_type not null default 'student',
  role user_role not null default 'user',
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  updated_at timestamp with time zone null default timezone('utc'::text, now()),
  constraint profiles_pkey primary key (id),
  constraint profiles_id_fkey foreign key (id) references auth.users (id) on delete cascade
) tablespace pg_default;

create table public.rooms (
  id uuid not null default gen_random_uuid(),
  name text not null,
  location text null,
  description text null,
  image_url text null,
  capacity integer not null default 5,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  updated_at timestamp with time zone null default timezone('utc'::text, now()),
  constraint rooms_pkey primary key (id),
  constraint rooms_name_check check (char_length(name) > 0),
  constraint rooms_capacity_check check (capacity > 0)
) tablespace pg_default;

create table public.room_slots (
  id uuid not null default gen_random_uuid(),
  room_id uuid not null,
  start_time time without time zone not null,
  end_time time without time zone not null,
  allowed_user_type user_type null default 'student',
  is_active boolean not null default true,
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  updated_at timestamp with time zone null default timezone('utc'::text, now()),
  constraint room_slots_pkey primary key (id),
  constraint room_slots_room_id_fkey foreign key (room_id) references rooms (id) on delete cascade,
  constraint room_slots_time_check check (end_time > start_time)
) tablespace pg_default;

create table public.room_bookings (
  id uuid not null default gen_random_uuid(),
  room_id uuid not null,
  slot_id uuid not null,
  booking_date date not null,
  organizer_id uuid not null,
  title text null,
  description text null,
  status text not null default 'booked'::text,
  participant_count integer not null default 1,
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  updated_at timestamp with time zone null default timezone('utc'::text, now()),
  constraint room_bookings_pkey primary key (id),
  constraint room_bookings_room_id_fkey foreign key (room_id) references rooms (id) on delete cascade,
  constraint room_bookings_slot_id_fkey foreign key (slot_id) references room_slots (id) on delete cascade,
  constraint room_bookings_organizer_id_fkey foreign key (organizer_id) references profiles (id) on delete cascade,
  constraint room_bookings_status_check check (status in ('booked', 'cancelled', 'completed', 'no_show')),
  constraint unique_room_slot_booking unique (room_id, slot_id, booking_date, status) deferrable initially deferred,
  constraint room_bookings_participant_count_check check (participant_count > 0)
) tablespace pg_default;

create table public.room_booking_participants (
  id uuid not null default gen_random_uuid(),
  booking_id uuid not null,
  participant_id uuid not null,
  is_organizer boolean not null default false,
  added_at timestamp with time zone not null default timezone('utc'::text, now()),
  removed_at timestamp with time zone null,
  status text not null default 'confirmed'::text,
  constraint room_booking_participants_pkey primary key (id),
  constraint room_booking_participants_booking_id_fkey foreign key (booking_id) references room_bookings (id) on delete cascade,
  constraint room_booking_participants_participant_id_fkey foreign key (participant_id) references profiles (id) on delete cascade,
  constraint unique_booking_participant unique (booking_id, participant_id),
  constraint room_booking_participants_status_check check (status in ('confirmed', 'declined', 'removed'))
) tablespace pg_default;

create table public.room_bookings_history (
  id uuid not null default gen_random_uuid(),
  original_booking_id uuid not null,
  room_id uuid not null,
  slot_id uuid not null,
  booking_date date not null,
  organizer_id uuid not null,
  title text null,
  description text null,
  status text not null,
  participant_count integer not null,
  booking_created_at timestamp with time zone not null,
  archived_at timestamp with time zone not null default timezone('utc'::text, now()),
  constraint room_bookings_history_pkey primary key (id),
  constraint room_bookings_history_room_id_fkey foreign key (room_id) references rooms (id) on delete cascade,
  constraint room_bookings_history_slot_id_fkey foreign key (slot_id) references room_slots (id) on delete cascade,
  constraint room_bookings_history_organizer_id_fkey foreign key (organizer_id) references profiles (id) on delete cascade
) tablespace pg_default;

create table public.room_booking_participants_history (
  id uuid not null default gen_random_uuid(),
  original_participant_id uuid not null,
  booking_id uuid not null,
  participant_id uuid not null,
  is_organizer boolean not null,
  added_at timestamp with time zone not null,
  removed_at timestamp with time zone null,
  status text not null,
  archived_at timestamp with time zone not null default timezone('utc'::text, now()),
  constraint room_booking_participants_history_pkey primary key (id),
  constraint room_booking_participants_history_participant_fkey foreign key (participant_id) references profiles (id) on delete cascade
) tablespace pg_default;
