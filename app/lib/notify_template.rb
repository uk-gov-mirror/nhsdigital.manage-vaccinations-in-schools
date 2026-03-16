# frozen_string_literal: true

class NotifyTemplate
  attr_reader :name, :channel, :id

  def self.find(name, channel:)
    name = name.to_sym
    channel = channel.to_sym

    if (template = CommsTemplate.find(name, channel:))
      new(name:, channel:, id: template.id, local: true)
    end
  end

  def self.find_by_id(template_id, channel:)
    return nil if template_id.blank?

    channel = channel.to_sym

    if (template = CommsTemplate.find_by_id(template_id, channel:))
      new(name: template.name, channel:, id: template_id.to_s, local: true)
    elsif (name = GOVUK_NOTIFY_UNUSED_TEMPLATES[template_id.to_s])
      new(name:, channel:, id: template_id.to_s, local: false)
    end
  end

  def self.exists?(name, channel:, source: :any)
    channel = channel.to_sym
    case source
    when :local, :any
      CommsTemplate.exists?(name, channel:)
    else
      raise ArgumentError, "Unknown source: #{source}"
    end
  end

  def self.all_ids(channel:)
    CommsTemplate.all_ids(channel:).freeze
  end

  def initialize(name:, channel:, id:, local:)
    @name = name.to_sym
    @channel = channel.to_sym
    @id = id
    @local = local
  end

  def local? = @local

  def render(personalisation)
    CommsTemplate.find(@name, channel: @channel).render(personalisation)
  end
end
