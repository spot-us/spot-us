module PitchesHelper
  def citizen_supporters_for(pitch)
    pitch.supporters - pitch.donations_and_credits.from_organizations.map(&:user)
  end
end
