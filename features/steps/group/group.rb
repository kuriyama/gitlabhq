class Groups < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths

  Then 'I should see projects list' do
    current_user.projects.each do |project|
      page.should have_link project.name
    end
  end

  And 'I have group with projects' do
    @group   = create(:group, owner: current_user)
    @project = create(:project, group: @group)
    @event   = create(:closed_issue_event, project: @project)

    @project.add_access current_user, :admin
  end

  And 'I should see projects activity feed' do
    page.should have_content 'closed issue'
  end

  Then 'I should see issues from this group assigned to me' do
    assigned_to_me(:issues).each do |issue|
      page.should have_content issue.title
    end
  end

  Then 'I should see merge requests from this group assigned to me' do
    assigned_to_me(:merge_requests).each do |issue|
      page.should have_content issue.title
    end
  end

  Given 'I have new user "John"' do
    create(:user, name: "John")
  end

  And 'I select user "John" from list with role "Reporter"' do
    user = User.find_by_name("John")
    within "#new_team_member" do
      select user.name, :from => "user_ids"
      select "Reporter", :from => "project_access"
    end
    click_button "Add"
  end

  Then 'I should see user "John" in team list' do
    projects_with_access = find(".ui-box .well-list")
    projects_with_access.should have_content("John")
  end

  Given 'project from group has issues assigned to me' do
    create :issue,
      project: project,
      assignee: current_user,
      author: current_user
  end

  Given 'project from group has merge requests assigned to me' do
    create :merge_request,
      project: project,
      assignee: current_user,
      author: current_user
  end

  protected

  def current_group
    @group ||= Group.first
  end

  def project
    current_group.projects.first
  end

  def assigned_to_me key
    project.send(key).where(assignee_id: current_user.id)
  end
end
