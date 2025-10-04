class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

# MY CODE!!!
def index
  @all_ratings = Movie.all_ratings

  # 1) Read incoming params (if any)
  incoming_ratings = params[:ratings]&.keys if params[:ratings].is_a?(ActionController::Parameters) || params[:ratings].is_a?(Hash)
  incoming_sort    = params[:sort_by] if %w[title release_date].include?(params[:sort_by])

  # 2) Fall back to session if params are missing
  selected_ratings = incoming_ratings || session[:ratings]
  sort_by          = incoming_sort    || session[:sort_by]

  # 3) If still nothing for ratings, default to "all"
  selected_ratings ||= @all_ratings

  # 4) If there were NO params but we do have remembered settings in session,
  #    redirect to a RESTful URL that includes them (so the URL reflects state).
  if params[:ratings].blank? || params[:sort_by].blank?
    # Rebuild a params-style hash for ratings: { 'G' => '1', 'PG' => '1', ... }
    ratings_hash = selected_ratings.map { |r| [r, '1'] }.to_h

    # Only redirect if at least one of the two was missing from params, to avoid loops
    missing_any = params[:ratings].blank? || params[:sort_by].blank?
    if missing_any
      return redirect_to movies_path(ratings: ratings_hash, sort_by: sort_by)
    end
  end

  # 5) Persist the (possibly new) choices into session
  session[:ratings] = selected_ratings
  session[:sort_by] = sort_by

  # 6) Expose to view and query
  @ratings_to_show = selected_ratings
  @sort_by         = sort_by || 'title'

  @movies = Movie
              .with_ratings(@ratings_to_show)
              .order(@sort_by => :asc)
end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
