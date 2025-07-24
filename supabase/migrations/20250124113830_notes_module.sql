-- Location: supabase/migrations/20250124113830_notes_module.sql
-- Notes Module - Building upon existing auth system
-- Schema Analysis: user_profiles table exists, user_role enum exists
-- Integration Type: Addition - new notes functionality
-- Dependencies: public.user_profiles table (from previous migration)

-- 1. Types for notes
CREATE TYPE public.note_color AS ENUM (
    'yellow',
    'green', 
    'blue',
    'pink',
    'purple',
    'orange',
    'white'
);

-- 2. Notes table (references existing user_profiles)
CREATE TABLE public.notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT '',
    content TEXT NOT NULL DEFAULT '',
    background_color public.note_color DEFAULT 'yellow'::public.note_color,
    is_pinned BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    is_task BOOLEAN DEFAULT false,
    completed BOOLEAN DEFAULT false,
    tags TEXT[] DEFAULT '{}',
    folder TEXT DEFAULT 'personal',
    reminder_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential indexes
CREATE INDEX idx_notes_user_id ON public.notes(user_id);
CREATE INDEX idx_notes_created_at ON public.notes(created_at DESC);
CREATE INDEX idx_notes_is_pinned ON public.notes(is_pinned);
CREATE INDEX idx_notes_is_archived ON public.notes(is_archived);
CREATE INDEX idx_notes_is_task ON public.notes(is_task);
CREATE INDEX idx_notes_folder ON public.notes(folder);
CREATE INDEX idx_notes_tags ON public.notes USING GIN(tags);

-- 4. Enable RLS
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- 5. Helper functions for RLS
CREATE OR REPLACE FUNCTION public.can_access_note(note_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.notes n
    WHERE n.id = note_uuid AND n.user_id = auth.uid()
)
$$;

-- 6. Update timestamp trigger
CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON public.notes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 7. RLS Policies
CREATE POLICY "users_can_manage_own_notes"
ON public.notes
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "admins_can_view_all_notes"
ON public.notes
FOR SELECT
TO authenticated
USING (public.is_admin());

-- 8. Mock Data for notes (references existing user_profiles)
DO $$
DECLARE
    admin_user_id UUID;
    regular_user_id UUID;
    demo_user_id UUID;
BEGIN
    -- Get existing user IDs from user_profiles
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@notetask.com' LIMIT 1;
    SELECT id INTO regular_user_id FROM public.user_profiles WHERE email = 'user@notetask.com' LIMIT 1;
    SELECT id INTO demo_user_id FROM public.user_profiles WHERE email = 'demo@notetask.com' LIMIT 1;

    -- Create sample notes for existing users
    IF admin_user_id IS NOT NULL THEN
        INSERT INTO public.notes (user_id, title, content, background_color, is_pinned, folder, tags) VALUES
            (admin_user_id, 'Meeting Notes', 'Discussed project timeline and deliverables. Need to follow up with team leads by Friday. Key points: budget approval, resource allocation, and milestone reviews.', 'yellow'::public.note_color, true, 'work', ARRAY['work', 'meeting']),
            (admin_user_id, 'App Feature Ideas', 'Dark mode toggle, Voice notes, AI summarization, Collaborative editing, Export to PDF, Reminder notifications', 'green'::public.note_color, false, 'work', ARRAY['work', 'development']);
    END IF;

    IF regular_user_id IS NOT NULL THEN
        INSERT INTO public.notes (user_id, title, content, background_color, is_pinned, folder, tags) VALUES
            (regular_user_id, 'Grocery List', 'Milk, Bread, Eggs, Apples, Chicken, Rice, Pasta, Tomatoes, Onions, Cheese', 'green'::public.note_color, false, 'personal', ARRAY['personal', 'shopping']),
            (regular_user_id, 'Workout Plan', 'Monday: Chest & Triceps\nTuesday: Back & Biceps\nWednesday: Legs\nThursday: Shoulders\nFriday: Cardio\nWeekend: Rest or light activity', 'pink'::public.note_color, true, 'personal', ARRAY['health', 'fitness']);
    END IF;

    IF demo_user_id IS NOT NULL THEN
        INSERT INTO public.notes (user_id, title, content, background_color, is_pinned, folder, tags) VALUES
            (demo_user_id, 'Book Ideas', '1. Time travel mystery novel\n2. Cookbook for busy professionals\n3. Guide to sustainable living\n4. Children''s book about friendship', 'blue'::public.note_color, false, 'ideas', ARRAY['ideas', 'creative']),
            (demo_user_id, 'Recipe: Pasta Carbonara', 'Ingredients: Spaghetti, Eggs, Parmesan cheese, Pancetta, Black pepper, Salt\n\nInstructions: Cook pasta, fry pancetta, mix eggs with cheese, combine all ingredients while hot.', 'orange'::public.note_color, false, 'personal', ARRAY['cooking', 'recipe']),
            (demo_user_id, 'Birthday Party Planning', 'Venue: Community center\nDate: Next Saturday\nGuests: 25 people\nFood: Pizza, cake, drinks\nDecorations: Balloons, streamers\nActivities: Games, music playlist', 'pink'::public.note_color, false, 'personal', ARRAY['personal', 'event']);
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 9. Functions for note management
CREATE OR REPLACE FUNCTION public.get_user_note_stats(target_user_id UUID)
RETURNS TABLE(
    total_notes BIGINT,
    total_tasks BIGINT,
    completed_tasks BIGINT,
    pinned_notes BIGINT,
    archived_notes BIGINT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    COUNT(*) FILTER (WHERE is_task = false AND is_archived = false) as total_notes,
    COUNT(*) FILTER (WHERE is_task = true AND is_archived = false) as total_tasks,
    COUNT(*) FILTER (WHERE is_task = true AND completed = true AND is_archived = false) as completed_tasks,
    COUNT(*) FILTER (WHERE is_pinned = true AND is_archived = false) as pinned_notes,
    COUNT(*) FILTER (WHERE is_archived = true) as archived_notes
FROM public.notes 
WHERE user_id = target_user_id;
$$;

-- 10. Search function for notes
CREATE OR REPLACE FUNCTION public.search_user_notes(
    target_user_id UUID,
    search_query TEXT DEFAULT '',
    note_folder TEXT DEFAULT NULL,
    include_archived BOOLEAN DEFAULT false
)
RETURNS TABLE(
    id UUID,
    title TEXT,
    content TEXT,
    background_color TEXT,
    is_pinned BOOLEAN,
    is_archived BOOLEAN,
    is_task BOOLEAN,
    completed BOOLEAN,
    tags TEXT[],
    folder TEXT,
    reminder_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    n.id,
    n.title,
    n.content,
    n.background_color::TEXT,
    n.is_pinned,
    n.is_archived,
    n.is_task,
    n.completed,
    n.tags,
    n.folder,
    n.reminder_at,
    n.created_at,
    n.updated_at
FROM public.notes n
WHERE n.user_id = target_user_id
    AND (include_archived = true OR n.is_archived = false)
    AND (note_folder IS NULL OR n.folder = note_folder)
    AND (
        search_query = '' OR 
        n.title ILIKE '%' || search_query || '%' OR 
        n.content ILIKE '%' || search_query || '%' OR 
        EXISTS (SELECT 1 FROM unnest(n.tags) AS tag WHERE tag ILIKE '%' || search_query || '%')
    )
ORDER BY n.is_pinned DESC, n.updated_at DESC;
$$;