class ArtistsController < ApplicationController
  def show
    artist = Artist.find(params[:id])
    albums = selected_albums(artist.albums, params[:album_type]).with_attached_cover.preload(:artist)
    tracks_limit = params[:tracks_limit] || 5
    tracks = artist.tracks.popularity_ordered.limit(tracks_limit)

    if turbo_frame_request?
      case turbo_frame_request_id
      when /discography/
        render partial: "discography", locals: {artist: artist, albums: albums}
      when /popular_tracks/
        render partial: "popular_tracks", locals: {artist: artist, tracks: tracks}
      end
    else
      render action: :show, locals: {artist: artist, albums: albums, tracks: tracks}
    end
  end

  private

  def selected_albums(albums, album_type)
    return albums.lp if album_type.blank?

    return albums.lp unless Album.kinds.key?(album_type)

    albums.where(kind: album_type)
  end
end
