class PullRequest < ApplicationRecord
  attr_accessor :message

  STATES = {
    open: 0,
    ready: 1,
    reviewing: 2,
    commented: 3,
    conflicted: 4,
    merged: 5,
    closed: 6,
    archived: 7
  }.freeze

  enum state: STATES, _prefix: true

  belongs_to :user, optional: true

  before_save :delete_current_reviewer, on: :update
  after_commit :broadcast_content
  after_create_commit :subscribe_repository
  after_create_commit :send_message
  after_update_commit :send_message, if: :state_previously_changed?
  after_update_commit :increment_merged

  scope :newest, ->{order updated_at: :desc}

  scope :by_single_state, (lambda do |state_param|
    where state: state_param.to_i unless state_param.blank?
  end)

  scope :by_state, (lambda do |state_param|
    where state: state_param if state_param.any?
  end)

  scope :by_room, (lambda do |room_param|
    where users: {room_id: room_param} if room_param.any?
  end)

  scope :by_repository, (lambda do |repository_param|
    where repository_id: repository_param if repository_param.any?
  end)

  scope :by_language, (lambda do |language_param|
    where users: {language: language_param} if language_param.any?
  end)

  delegate :name, :room_id, :chatwork, :to_cw, :to_cc, :html_url,
    to: :user, prefix: true, allow_nil: true

  def html_path
    "#{full_name}/pull/#{number}"
  end

  def html_url
    "https://github.com/#{html_path}"
  end

  private

  def delete_current_reviewer
    return if state_reviewing?
    self.current_reviewer = nil
    self.reviewer_picon = nil
  end

  def broadcast_content
    return if previous_changes.empty?
    ActionCable.server.broadcast "pull_requests",
      id: id, deleted: destroyed?,
      state: state_before_type_cast.to_s,
      room_id: user_room_id.to_s,
      repository_id: repository_id.to_s,
      html: PullRequestsController.render(self)
  end

  def subscribe_repository
    return unless user_chatwork
    Subscription.create repository_id: repository_id,
      user_id: user_id, subscriber: user_to_cc
  end

  def send_message
    return if state_open? && message.blank?
    return if state_archived?
    return unless user_chatwork && user_room_id

    params = {
      id: id,
      url: html_url,
      state: state,
      repository_id: repository_id,
      number: number,
      reviewer: reviewer_picon,
      message: message,
      room_id: user_room_id,
      user_id: user_id,
      user_cw: user_to_cw
    }

    ChatworkWorker.perform_async params
  end

  def increment_merged
    return unless state_previously_changed? && state_merged?
    user&.increment! :merged
  end
end
