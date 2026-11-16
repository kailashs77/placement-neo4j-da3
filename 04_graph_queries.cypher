// =====================================================================
// E. GRAPH-SPECIFIC QUERIES
// Run one statement at a time. E3 and E8 return paths - view them in
// the Graph tab of the Aura Query editor for the picture.
// =====================================================================

// ---------------------------------------------------------------------
// E1. Skill match - opportunities S005 has NOT applied to, but for which
// they already have at least one required skill. One pattern covers
// internships AND job offers.
// ---------------------------------------------------------------------
MATCH (s:Student {student_id:'S005'})-[:HAS_SKILL]->(sk)<-[:REQUIRES_SKILL]-(o)
WHERE NOT EXISTS { (s)-[:SUBMITTED]->()-[:FOR]->(o) }
RETURN o.opportunity_id, o.title, collect(sk.name) AS matching_skills
ORDER BY size(matching_skills) DESC;

// E1b. Strict version - only opportunities where the student has ALL
// the required skills.
MATCH (s:Student {student_id:'S005'}), (o:Opportunity)
WHERE NOT EXISTS { (s)-[:SUBMITTED]->()-[:FOR]->(o) }
  AND ALL(req IN [(o)-[:REQUIRES_SKILL]->(k) | k] WHERE EXISTS { (s)-[:HAS_SKILL]->(req) })
MATCH (c:Company)-[:OFFERS]->(o)
RETURN o.opportunity_id, o.title, c.name AS company;

// ---------------------------------------------------------------------
// E2. Faculty funnel - per coordinator: students guided, how many
// applied, how many placed (accepted an offer).
// ---------------------------------------------------------------------
MATCH (f:FacultyCoordinator)-[:GUIDES]->(s:Student)
WITH f, s,
     EXISTS { (s)-[:SUBMITTED]->() } AS has_applied,
     EXISTS { (s)-[:ACCEPTED]->() }  AS is_placed
RETURN f.first_name + ' ' + f.last_name              AS coordinator,
       count(s)                                      AS guided,
       sum(CASE WHEN has_applied THEN 1 ELSE 0 END)  AS applied,
       sum(CASE WHEN is_placed   THEN 1 ELSE 0 END)  AS placed
ORDER BY coordinator;

// ---------------------------------------------------------------------
// E3. Shortest path - how two students are connected
// (e.g. S001 -> Computer Science <- S005, or through a shared skill)
// ---------------------------------------------------------------------
MATCH p = shortestPath(
  (:Student {student_id:'S001'})-[*..6]-(:Student {student_id:'S005'})
)
RETURN p;

// E3b. A longer one across departments: S001 (CSE) to S006 (MECH)
MATCH p = shortestPath(
  (:Student {student_id:'S001'})-[*..8]-(:Student {student_id:'S006'})
)
RETURN p, length(p) AS hops;

// ---------------------------------------------------------------------
// E4. Shared skills - pairs of students with common skills (peer groups)
// ---------------------------------------------------------------------
MATCH (a:Student)-[:HAS_SKILL]->(sk:Skill)<-[:HAS_SKILL]-(b:Student)
WHERE a.student_id < b.student_id
RETURN a.first_name AS student_1, b.first_name AS student_2,
       collect(sk.name) AS common_skills, count(sk) AS shared
ORDER BY shared DESC, student_1;

// ---------------------------------------------------------------------
// E5. Derived Number_of_Openings - not stored, computed by counting
// the OFFERS relationships of each company.
// ---------------------------------------------------------------------
MATCH (c:Company)
OPTIONAL MATCH (c)-[:OFFERS]->(o:Opportunity)
RETURN c.name AS company,
       count(o) AS number_of_openings,
       sum(CASE WHEN o:Internship THEN 1 ELSE 0 END) AS internships,
       sum(CASE WHEN o:JobOffer   THEN 1 ELSE 0 END) AS job_offers
ORDER BY number_of_openings DESC, company;

// ---------------------------------------------------------------------
// E6. Derived CONDUCTS - which company held each interview. There is no
// stored Company_ID on Interview; it is reached by traversal
// Company -> Opportunity <- Application -> Interview.
// ---------------------------------------------------------------------
MATCH (c:Company)-[:OFFERS]->(o)<-[:FOR]-(a:Application)-[:HAS_INTERVIEW]->(i:Interview),
      (s:Student)-[:SUBMITTED]->(a)
RETURN i.interview_id, c.name AS conducted_by, s.first_name AS student,
       o.title AS opportunity, i.interview_date, i.result
ORDER BY i.interview_date;

// ---------------------------------------------------------------------
// E7. Skill demand vs. supply - how many opportunities need each skill
// and how many students have it.
// ---------------------------------------------------------------------
MATCH (sk:Skill)
RETURN sk.name AS skill,
       COUNT { (sk)<-[:REQUIRES_SKILL]-(:Opportunity) } AS required_by_opportunities,
       COUNT { (sk)<-[:HAS_SKILL]-(:Student) }          AS students_with_skill
ORDER BY required_by_opportunities DESC, skill;

// ---------------------------------------------------------------------
// E8. Company network - one company's offers, applications and students
// as a picture (open the Graph tab).
// ---------------------------------------------------------------------
MATCH p = (c:Company {company_id:'C01'})-[:OFFERS]->(o)<-[:FOR]-(a:Application)<-[:SUBMITTED]-(s:Student)
OPTIONAL MATCH q = (a)-[:HAS_INTERVIEW]->(:Interview)
RETURN p, q;

// E9. Whole graph - the full model in one picture (41+ nodes)
MATCH (n)
OPTIONAL MATCH (n)-[r]->(m)
RETURN n, r, m;
