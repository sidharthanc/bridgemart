describe 'ActiveAdmin Comments', type: :request do
  let(:admin_group) { permission_groups(:admin) }
  let(:user) { users(:joseph) }
  let(:comment) do
    ActiveAdmin::Comment.create(
      namespace: 'admin',
      body: 'comment here',
      resource_type: 'User',
      resource_id: users(:test).id,
      author_type: 'User',
      author_id: user.id
    )
  end

  before { sign_in user }

  context 'admin user' do
    before { user.permission_groups = [admin_group] }

    it 'can delete a comment' do
      visit admin_comment_path(comment)
      expect do
        click_link('Delete Comment', href: admin_comment_path(comment))
      end.to change(ActiveAdmin::Comment, :count).by(-1)

      expect(page.current_path).to eq(admin_comments_path)
    end
  end
end
