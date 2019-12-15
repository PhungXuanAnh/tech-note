The step by step to optimize mongodb query

- **Always \$match and \$sort** first in the query or aggrigate pipeline 
- Create Indexes to Support Queries filter both **\$match** and **\$sort**
- Limit the Number of Query Results to Reduce Network Demand
- Use **\$project** to Return Only Necessary Data
- Use **\$hint** to Select a Particular Index
- Use the Increment Operator to Perform Operations Server-Side