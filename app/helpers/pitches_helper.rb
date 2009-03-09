module PitchesHelper
  def citizen_supporters_for(pitch)
    pitch.supporters - pitch.donations.from_organizations.map(&:user)
  end
end
