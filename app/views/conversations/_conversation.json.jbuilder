json.extract! conversation, :id, :subject, :contact_id, :created_at, :updated_at
json.url conversation_url(conversation, format: :json)
