class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @rating_checked =
    if !params[:ratings].nil?
      @selected_ratings = []
      @ratings = params[:ratings]
      @ratings.each do |key, value|
        @selected_ratings << key
      end
      @query_ratings = @selected_ratings
    elsif !session[:ratings].nil?
      @selected_ratings = []
      @ratings = session[:ratings]
      @ratings.each do |key, value|
        @selected_ratings << key
      end
      @query_ratings = @selected_ratings
    else
      @query_ratings = Movie.all_ratings
    end

    if params[:sort_title] == 'hilite'
      @movies = Movie.where(:rating => @query_ratings, :order => "title ASC")
      #@movies = Movie.all(:order => "title ASC")
    elsif params[:sort_date] == 'hilite'
      @movies = Movie.where(:rating => @query_ratings, :order => "release_date ASC")
      #@movies = Movie.all(:order => "release_date ASC")
    else
      @movies = Movie.where(:rating => @query_ratings)
      #@movies = Movie.all
    end

    @all_ratings = Movie.all_ratings

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
