class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @rating_checked = {}                      # this is used to re-set the check boxes
    @selected_ratings = []                    # this is used to pass the ratings array to the db query

    if !params[:ratings].nil?                 # only do this if there ARE selected ratings
      @ratings = params[:ratings]
      @ratings.each do |key, value|
        @selected_ratings << key
        @rating_checked[key] = true
      end
      session[:ratings] = @selected_ratings
    elsif params[:commit] == 'Refresh'        # do this if there aren't selected ratings, but Refresh param was there
      Movie.all_ratings.each do |r|           # - this would mean that someone unselected all checkboxes but did a
        @rating_checked[r] = true             # - Refresh of selected movies based on ratings
      end
      @selected_ratings = Movie.all_ratings
      session[:ratings] = @selected_ratings
    elsif !session[:ratings].nil?             # you have come from a different page and need to reset the ratings from
      @ratings = session[:ratings]            # - a prior selection
      @ratings.each do |key, value|
        @selected_ratings << key
        @rating_checked[key] = true
      end
    else
      Movie.all_ratings.each do |r|           # no refresh button, no prior session, probably the first time in to the
        @rating_checked[r] = true             # - page
      end
      @selected_ratings = Movie.all_ratings
    end

    if params[:sort_title] == 'hilite'
      @movies = Movie.find_all_by_rating(@selected_ratings).sort_by { |m| m.title }
      session[:sort_title] = 'hilite'
      session.delete(:sort_date)
    elsif params[:sort_date] == 'hilite'
      @movies = Movie.find_all_by_rating(@selected_ratings).sort_by { |m| m.release_date }
      session[:sort_date] = 'hilite'
      session.delete(:sort_title)
    elsif session[:sort_title] == 'hilite'
      @movies = Movie.find_all_by_rating(@selected_ratings).sort_by { |m| m.title }
    elsif session[:sort_date] == 'hilite'
      @movies = Movie.find_all_by_rating(@selected_ratings).sort_by { |m| m.release_date }
    else
      @movies = Movie.where(:rating => @selected_ratings)
    end

    @all_ratings = Movie.all_ratings           # setup the @all_ratings variable for the view

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
