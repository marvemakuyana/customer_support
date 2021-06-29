class ApplicationMailbox < ActionMailbox::Base
  # conversation-12345@example.com -> ReplyMailbox
  routing ReplyMailbox::MATCHER => :reply

  # support@example.com -> ConversationMailbox
  routing :all => :conversation

  before_processing :save_attachments

  attr_reader :attachments

  def from
    @from ||= mail[:from].address_list.addresses.first
  end

  def author
    if(user = User.find_by(email: from.address))
      user
    else
      contact
    end
  end
  
  def contact
    contact = Contact.where(email: from.address).first_or_initialize
    contact.update(name: from.display_name)
    contact
  end

  def body
    if mail.multipart? && mail.html_part
      process_html
    elsif mail.multipart? && mail.text_part
      mail.text_part.body.decoded
    else
      mail.decoded
    end
  end  

  def process_html
    document = Nokogiri::HTML(mail.html_part.body.decoded)

    attachments.each do |attachment_hash|
      content_id = attachment_hash[:content_id]
      next unless content_id

      blob = attachment_hash[:blob]
      element = document.at_css "img[src='cid:#{content_id}']"
      element.replace "<action-text-attachment sgid=\"#{blob.attachable_sgid}\" content-type=\"#{blob.content_type}\" filename=\"#{blob.filename}\"></action-text-attachment>"
    end

    document.at_css("body").inner_html.encode("utf-8")
  end
 
  def save_attachments
     @attachments = mail.attachments.map do |attachment|
      blob = ActiveStorage::Blob.create_after_upload!(
        io: StringIO.new(attachment.body.to_s),
        filename: attachment.filename,
        content_type: attachment.content_type
      )
      { blob: blob, content_id: (attachment.content_id[1...-1] if attachment.content_id)}
     end
  end
end
