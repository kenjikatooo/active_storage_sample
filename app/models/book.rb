class Book < ApplicationRecord

  # ファイルをモデルと紐づける
  # active_storage_〜というテーブルにここの名前が保存され、book_imageから画像を取り出せる
  # ex : Book.first.book_image => Book.firstの画像
  # つまり画像用のカラムをつくる必要はない
  has_one_attached :book_image
  attr_accessor :image

  # 画像をactivestorageに保存するメソッド
  def parse_base64(image)
    if image.present? || rex_image(image) == ''
      # create_extensionで拡張子が何かを調べる
      content_type = create_extension(image)
      
      # base64の `data:image/png;base64` の後のコードを抜き出す
      contents = image.sub %r/data:((image|application)\/.{3,}),/, ''
      
      # 抜き出したものをデコードする
      decoded_data = Base64.decode64(contents)

      # 書き出したファイルを一時的にローカルに保存する
      filename = Time.zone.now.to_s + '.' + content_type
      File.open("#{Rails.root}/tmp/#{filename}", 'wb') do |f|
        f.write(decoded_data)
      end
    end
    # activestorageに保存して、ローカルのものを削除する
    attach_image(filename)
  end

  private

  def create_extension(image)
    content_type = rex_image(image)
    content_type[%r/\b(?!.*\/).*/]
  end

  def rex_image(image)
    image[%r/(image\/[a-z]{3,4})|(application\/[a-z]{3,4})/]
  end

  def attach_image(filename)
    book_image.attach(io: File.open("#{Rails.root}/tmp/#{filename}"), filename: filename)
    FileUtils.rm("#{Rails.root}/tmp/#{filename}")
  end
end
