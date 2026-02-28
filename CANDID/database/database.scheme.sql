-- the PSQL schema for the project of Candid--
CREATE TABLE IF NOT EXISTS universities(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    admin_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- university admin who is responsible for variying the requests of the teachers to join
CREATE TABLE IF NOT EXISTS  university_admins(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    university_id UUID REFERENCES universities(id),
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- university teacher who is responsible for creating the courses and approving the project requests created by students, students will create a  project by tagging the skills and the teacher will check and approve 
CREATE TABLE IF NOT EXISTS university_teachers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    university_id UUID REFERENCES universities(id),
    password VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

)

-- student who is responsible for creating the projects and tagging the skills needed for the project and then the teacher will check and approve the project
CREATE TABLE IF NOT EXISTS students(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    university_id UUID REFERENCES universities(id),
    admin_id UUID REFERENCES university_admins(id) ,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
)




--projects table where the project data is stored and the teacher will check and approve the project
CREATE TABLE IF NOT EXISTS projects(
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    student_id UUID REFERENCES students(id),
    teacher_id UUID REFERENCES university_teachers(id),
    university_id UUID REFERENCES universities(id),
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
--skills table where all skills are saved and  the student will attach the needed skills for the project and the teacher will check and approve the project
CREATE TABLE IF NOT EXISTS skills(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL, -- 'university', 'vacancy', 'project'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- joint table to store the many-to-many relationship between projects and skills
CREATE TABLE IF NOT EXISTS project_skills(
    id SERIAL PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    skill_id UUID REFERENCES skills(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- github links
CREATE TABLE IF NOT EXISTS github_link(
    id SERIAL PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    link VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- deployment links
CREATE TABLE IF NOT EXISTS deployment_link(
    id SERIAL PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    link VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)


--github repo languages table 
CREATE TABLE IF NOT EXISTS github_repo_languages(
    id SERIAL PRIMARY KEY,
    repo_id UUID REFERENCES github_repos(id),
    name VARCHAR(255) NOT NULL,
    bytes UUID NOT NULL,
)
--github repos list--
CREATE TABLE IF NOT EXISTS github_repos(
    id SERIAL PRIMARY KEY,
    repoId VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    fullName VARCHAR(255) NOT NULL,
    url VARCHAR(255) NOT NULL,
    description TEXT,
    visibility VARCHAR(50) NOT NULL,
    stars UUID NOT NULL,
    forks UUID NOT NULL,
    pushedAt TIMESTAMP NOT NULL,
    selected BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    selected BOOLEAN DEFAULT FALSE
)

-- employer table where we store the employer data
CREATE TABLE IF NOT EXISTS employers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    company VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)


--internship table where we store the internship data
CREATE TABLE IF NOT EXISTS vacancies(
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- internship vs job
    description TEXT NOT NULL,
    company VARCHAR(255) NOT NULL,
    employer_id UUID REFERENCES employers(id),
    location VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    mode VARCHAR(50) NOT NULL, --remote vs onsite
    salary VARCHAR(255) NOT NULL,
    is_expired BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

-- joint table to store the many-to-many relationship between vacancies and skills
CREATE TABLE IF NOT EXISTS vacancy_skills(
    id SERIAL PRIMARY KEY,
    vacancy_id UUID REFERENCES vacancies(id),
    skill_id UUID REFERENCES skills(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)




-- messages table to store the messages betweeen the students and teachers and the projects and vacancies
CREATE TABLE IF NOT EXISTS messages(
    id SERIAL PRIMARY KEY,
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    role VARCHAR(50) NOT NULL, -- 'student', 'teacher', 'project', 'vacancy'
    content TEXT NOT NULL,
    attachment_links TEXT[], -- array of links to attachments
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- many to many table to store the relationship between students and vacancies for the applications
CREATE TABLE IF NOT EXISTS student_vacancy_applications(
    id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(id),
    vacancy_id UUID REFERENCES vacancies(id),
    status VARCHAR(50) NOT NULL, -- 'applied', 'interviewing', 'accepted', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)



-- many to many table to store the relationship between students and projects for the applications
CREATE TABLE IF NOT EXISTS student_project_applications(
    id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(id),
    project_id UUID REFERENCES projects(id),
    status VARCHAR(50) NOT NULL, -- 'applied', 'interviewing', 'accepted', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- many to many table to store the relationship between teachers and projects for the applications
CREATE TABLE IF NOT EXISTS teacher_project_applications(
    id SERIAL PRIMARY KEY,
    teacher_id UUID REFERENCES university_teachers(id),
    project_id UUID REFERENCES projects(id),
    status VARCHAR(50) NOT NULL, -- 'applied', 'interviewing', 'accepted', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- many to many table to store the students and messages relationship
CREATE TABLE IF NOT EXISTS student_messages(
    id SERIAL PRIMARY KEY,
    student_id UUID REFERENCES students(id),
    message_id UUID REFERENCES messages(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
-- many to many table to store the teachers and messages relationship
CREATE TABLE IF NOT EXISTS teacher_messages(
    id SERIAL PRIMARY KEY,
    teacher_id UUID REFERENCES university_teachers(id),
    message_id UUID REFERENCES messages(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)