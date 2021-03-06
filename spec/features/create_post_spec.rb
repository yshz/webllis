require 'rails_helper'

feature 'User management' do
  let(:user) { create(:user) }

  before do
    Capybara.app_host = 'http://www.example.com'
    login user
    click_link '投稿する'
  end

  scenario '新しい投稿を追加する' do
    fill_in 'URL', with: 'http://webllis.com'
    fill_in 'タイトル', with: 'タイトル'
    fill_in '説明', with: '説明です。'
    # attach_file '画像'.
      # File.new("#{Rails.root}/spec/factories/image.png")
    click_button '投稿'

    user.reload
    expect(user.posts.size).to eq(1)
    expect(user.posts[0].url).to eq('http://webllis.com')
    # expect(user.posts.last.avatar_file_name).to eq 'image.png'
  end

  scenario 'ログインユーザが無効な値を入力する' do
    fill_in 'URL', with: 'webllis.com'
    fill_in 'タイトル', with: 'タイトル'
    fill_in '説明', with: '説明です。'
    click_button '投稿'

    # TODO: エラーの表示
  end
end
