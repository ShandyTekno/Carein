-- ============================================================
-- AISKIN: SQL untuk membuat tabel skin_analysis di Supabase
-- Jalankan ini di Supabase Dashboard → SQL Editor
-- ============================================================

-- Tabel utama riwayat analisis kulit
CREATE TABLE IF NOT EXISTS public.skin_analysis (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now() NOT NULL,

  -- Hasil skor
  score       INTEGER NOT NULL CHECK (score BETWEEN 0 AND 100),
  skin_type   TEXT NOT NULL,
  insight     TEXT NOT NULL,

  -- Metrik individual (0–100)
  acne        NUMERIC(5,1) NOT NULL DEFAULT 0,
  oiliness    NUMERIC(5,1) NOT NULL DEFAULT 0,
  dullness    NUMERIC(5,1) NOT NULL DEFAULT 0,
  dark_spot   NUMERIC(5,1) NOT NULL DEFAULT 0,
  texture     NUMERIC(5,1) NOT NULL DEFAULT 0,
  redness     NUMERIC(5,1) NOT NULL DEFAULT 0
);

-- Row Level Security: setiap user hanya bisa lihat datanya sendiri
ALTER TABLE public.skin_analysis ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own analyses"
  ON public.skin_analysis FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analyses"
  ON public.skin_analysis FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own analyses"
  ON public.skin_analysis FOR DELETE
  USING (auth.uid() = user_id);

-- Index untuk query riwayat terbaru
CREATE INDEX IF NOT EXISTS idx_skin_analysis_user_date
  ON public.skin_analysis (user_id, created_at DESC);
