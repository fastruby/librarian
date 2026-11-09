class AddShareToSocialMediaSnippets < ActiveRecord::Migration[7.0]
  # Optional link back to the tracked share (short URL) a snippet was posted
  # with. Nullable because every existing snippet predates it, and nullified
  # (not blocked) when a share is deleted, so removing a share never fails
  # because of the copy that points at it.
  def change
    add_reference :social_media_snippets, :share, null: true, index: true,
                  foreign_key: { on_delete: :nullify }
  end
end
