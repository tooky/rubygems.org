class ProfilesController < ApplicationController
  before_filter :redirect_to_root, :unless => :signed_in?, :except => :show

  def edit
  end

  def show
    DisplaysUserProfile.new(self, params[:id]).display
  end

  def display_profile(user, rubygems, extra_rubygems)
    self.page = ProfilePage.new(user, rubygems, extra_rubygems)
    render :show
  end

  def update
    if current_user.update_attributes(params[:user])
      if current_user.email_reset
        sign_out
        flash[:notice] = "You will receive an email within the next few minutes. " <<
                         "It contains instructions for reconfirming your account with your new email address."
        redirect_to root_path
      else
        flash[:notice] = "Your profile was updated."
        redirect_to edit_profile_path
      end
    else
      render :edit
    end
  end

  ProfilePage = Struct.new(:user, :rubygems, :extra_rubygems)

  class DisplaysUserProfile
    def initialize(context, user_id)
      @context = context
      @user_id = user_id
    end

    def display
      user           = User.find_by_slug!(@user_id)
      rubygems       = user.rubygems_downloaded
      @context.display_profile(user, rubygems.slice(0,10), rubygems.slice(10..-1))
    end
  end

  attr_accessor :page
  helper_method :page
end
