class User < ActiveRecord::Base
  include NameHolder
  include EmailHolder
  include PasswordHolder

  has_many :events, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: 'followed_id',
    class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :favorites, dependent: :destroy
  has_many :favorite_posts, through: :favorites, source: :post

  before_create :create_remember_token

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def active?
    !suspended?
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def feed
    Post.from_users_followed_by(self)
  end

  def favorite?(other_post)
    favorites.find_by(post_id: other_post.id)
  end

  def add_favorite!(other_post)
    favorites.create!(post_id: other_post.id)
  end

  def remove_favorite!(other_post)
    favorites.find_by(post_id: other_post.id).destroy
  end

  private
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
