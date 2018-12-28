class BooksController < ApplicationController
  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      @book.parse_base64(params[:image])
      render json: @book, status: :created, location: @book
    else
      render json: @book.errors, status: :unprocessable_entity
    end
  end

  # GET /books
  def index
    @books = Book.with_attached_book_image
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  private

  def book_params
    params.require(:book).permit(:title, :image)
  end
end
