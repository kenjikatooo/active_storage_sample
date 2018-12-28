if @books.present?
  json.books do
    json.array!(@books) do |book|
      json.extract! book, :id, :title
      json.image rails_blob_url(book.book_image) if book.book_image.attached?
    end
  end
end
