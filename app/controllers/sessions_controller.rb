class SessionsController < ApplicationController
  def new

  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message = 'Account wurde noch nicht aktiviert.'
        message += 'Bitte check deine Mails für den Aktivierungslink'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Ungültige Kombination von Email und Passwort!'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
