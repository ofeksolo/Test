import jenkins
import sys
# Could mask the password by encrypting it using base64 
# And fetching the encrypted password from a file and decrypting it inside the script.
jenkins_server = jenkins.Jenkins('http://localhost:8080/', username='admin', 
                         password='Aa123456')
job = sys.argv[1]
job_name = jenkins_server.get_job_name(job)
if job_name == None:
    print ("Error: There is no such job {}".format(job))
    sys.exit(1)
else:
    print ("The name of the job that initiated me is {}".format(job_name))

# Could also do it by only printing the sys.argv
# As im passing env.JOB_NAME as argument when running the script from Jenkins.