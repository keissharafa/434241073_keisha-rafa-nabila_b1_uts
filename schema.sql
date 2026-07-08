-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.tickets (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ticket_code text NOT NULL UNIQUE,
  title text NOT NULL,
  description text,
  category text DEFAULT 'Technical Support'::text,
  status text NOT NULL DEFAULT 'OPEN'::text,
  priority text,
  requested_priority text,
  assigned_to text,
  reporter text DEFAULT 'Alex Johnson'::text,
  source text DEFAULT 'Mobile App'::text,
  strikethrough boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  attachment_url text,
  CONSTRAINT tickets_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ticket_comments (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ticket_id bigint,
  sender_role text NOT NULL,
  sender_name text NOT NULL,
  message text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  attachment_url text,
  CONSTRAINT ticket_comments_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.notifications (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  role_target text NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  ticket_id bigint,
  status text,
  notification_type text DEFAULT 'info'::text,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  full_name text,
  email text UNIQUE,
  username text UNIQUE,
  password text,
  role text DEFAULT 'user'::text,
  division text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);