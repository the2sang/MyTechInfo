class Clubs::AssignManagerByEmailService
  def self.call(user: nil, club: nil)
    if user
      Club.where(contact_email: user.email_address).find_each { |c| assign(user, c) }
    elsif club
      return unless club.contact_email.present?
      matched = User.find_by(email_address: club.contact_email)
      assign(matched, club) if matched
    end
  end

  def self.assign(user, club)
    membership = club.club_memberships.find_or_initialize_by(user: user)
    membership.assign_attributes(role: :manager, status: :approved)
    membership.save!
  end
  private_class_method :assign
end
