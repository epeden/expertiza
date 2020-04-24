describe "view team reviews test" do
  before(:each) do
    # create assignment and topic
    @instructor = create(:instructor)
    course = create(:course)
    @assignment = create(:assignment, name: "TestAssignment", directory_path: "TestAssignment")
    @student1 = create(:student, name: "student1")
    create(:topic, topic_name: "Topic")
    create(:deadline_type, name: "submission")
    create(:deadline_type, name: "review")
    create(:deadline_type, name: "metareview")
    create(:deadline_type, name: "drop_topic")
    create(:deadline_type, name: "signup")
    create(:deadline_type, name: "team_formation")
    create(:deadline_right)
    create(:deadline_right, name: 'Late')
    create(:deadline_right, name: 'OK')
    create(:assignment_due_date, deadline_type: DeadlineType.where(name: "review").first, due_at: DateTime.now.in_time_zone + 1.day)
    @student1_participant = create(:participant, assignment: @assignment, user: @student1)
    @team = create(:assignment_team, id: 1)
    create(:team_user)
    create(:questionnaire)
    create(:assignment_questionnaire)
    create(:question)
    submit_assignment
    stub_current_user(@student1, @student1.role.name, @student1.role)
  end

  def signup_topic
    stub_current_user(@student1, @student1.role.name, @student1.role)
    visit '/student_task/list'
    visit '/sign_up_sheet/sign_up?id=1&topic_id=1' # signup topic
    visit '/student_task/list'
    click_link "TestAssignment"
    click_link "Your work"
  end

  def submit_assignment
    signup_topic
    fill_in 'submission', with: "https://www.ncsu.edu"
    click_on 'Upload link'
    expect(page).to have_content "https://www.ncsu.edu"
    # open the link and check content
    click_on "https://www.ncsu.edu"
    expect(page).to have_http_status(200)
  end

  def submit_review_as_student
    student2 = create(:student, name: "student2")
    student2_participant = create(:participant, assignment: @assignment, user: student2)
    rm = create(:review_response_map, assignment: @assignment, reviewer: student2_participant, reviewee: @team )
    create(:response, response_map: rm, is_submitted: true)
  end

  def submit_review_as_instructor
    instructor_participant = create(:participant, assignment: @assignment, user: @instructor)
    rm = create(:review_response_map, assignment: @assignment, reviewer: instructor_participant, reviewee: @team )
    create(:response, response_map: rm, is_submitted: true)
  end


  context "when review is by an instructor" do
    it "should show star icon" do
      submit_review_as_instructor
      stub_current_user(@student1, @student1.role.name, @student1.role)
      visit '/student_task/list'
      click_on "TestAssignment"
      click_on "Your scores"
      expect(page).to have_css("glyphicon glyphicon-star")
    end
  end

  context "when review is by a student" do
    it "should not show star icon" do
      submit_review_as_student
      stub_current_user(@student1, @student1.role.name, @student1.role)
      visit '/student_task/list'
      click_on "TestAssignment"
      click_on "Your scores"
      expect(page).to have_content "Review 1"
    end
  end

end
