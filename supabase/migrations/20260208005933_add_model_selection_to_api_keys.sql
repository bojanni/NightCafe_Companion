/*
  # Add Model Selection Support

  1. Changes
    - Add `model_name` column to `user_api_keys` table to store selected model
    - Add `model_name` column to `user_local_endpoints` table for consistency
  
  2. Details
    - Allows users to select specific models for each provider
    - Stores the active model choice alongside the API key
    - Enables provider + model activation
*/

-- Add model_name to user_api_keys
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_api_keys' AND column_name = 'model_name'
  ) THEN
    ALTER TABLE user_api_keys ADD COLUMN model_name text;
  END IF;
END $$;

-- Add model_name to user_local_endpoints (if not exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'user_local_endpoints'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'user_local_endpoints' AND column_name = 'model_name'
    ) THEN
      ALTER TABLE user_local_endpoints ADD COLUMN model_name text;
    END IF;
  END IF;
END $$;

-- Update existing records to have a model_name if they don't
UPDATE user_api_keys 
SET model_name = CASE 
  WHEN provider = 'openai' THEN 'gpt-4o'
  WHEN provider = 'gemini' THEN 'gemini-2.0-flash-exp'
  WHEN provider = 'anthropic' THEN 'claude-sonnet-4-20250514'
  WHEN provider = 'openrouter' THEN 'openai/gpt-4o'
  ELSE NULL
END
WHERE model_name IS NULL;
