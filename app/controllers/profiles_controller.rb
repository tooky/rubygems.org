class ProfilesController < ApplicationController
  before_filter :redirect_to_root, :unless => :signed_in?, :except => :show

  def edit
  end

  def show
    user           = User.find_by_slug!(params[:id])
    rubygems       = user.rubygems_downloaded

    profile_page = ProfilePage.new(user, rubygems.slice(0,10), rubygems.slice(10..-1))
    display_profile(profile_page)
  end

  def display_profile(page)
    @user = page.user
    @rubygems = page.rubygems
    @extra_rubygems = page.extra_rubygems
    render :show
  end

  ProfilePage = Struct.new(:user, :rubygems, :extra_rubygems)

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
end
