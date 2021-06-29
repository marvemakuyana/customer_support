class ReplyMailbox < ApplicationMailbox
  MATCHER = /^conversation-(\d+)@/i

  def process
    conversation.posts.create(
      author: author,
      body: body,
      message_id: mail.message_id
    )
  end

  def conversation
    Conversation.find(conversation_id)
  end

  def conversation_id
    mail.recipients.find{ |recipient| MATCHER.match?(recipient) }[MATCHER, 1]
  end
end
