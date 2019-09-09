//
// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

# JSON delete operator client.
public type JsonDeleteOperator client object {
    JobInfo job;
    SalesforceBaseClient httpBaseClient;

    public function __init(JobInfo job, SalesforceConfiguration salesforceConfig) {
        self.job = job;
        self.httpBaseClient = new(salesforceConfig);
    }

    # Create JSON delete batch.
    #
    # + payload - delete data with IDs in JSON format
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function delete(json payload) returns @tainted BatchInfo|ConnectorError {
        json | ConnectorError response = self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id,
        <@untainted> BATCH], payload);
        if (response is json) {
            BatchInfo|ConnectorError batch = getBatch(response);
            return batch;
        } else {
            return response;
        }
    }

    # Get JSON delete operator job information.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function getJobInfo() returns @tainted JobInfo|ConnectorError {
        json | ConnectorError response = self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id]);
        if (response is json) {
            JobInfo|ConnectorError job = getJob(response);
            return job;
        } else {
            return response;
        }
    }

    # Close JSON delete operator job.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function closeJob() returns @tainted JobInfo|ConnectorError {
        json | ConnectorError response = self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id],
        JSON_STATE_CLOSED_PAYLOAD);
        if (response is json) {
            JobInfo|ConnectorError job = getJob(response);
            return job;
        } else {
            return response;
        }
    }

    # Abort JSON delete operator job.
    #
    # + return - JobInfo record if successful else ConnectorError occured
    public remote function abortJob() returns @tainted JobInfo|ConnectorError {
        json | ConnectorError response = self.httpBaseClient->createJsonRecord([<@untainted> JOB, self.job.id],
        JSON_STATE_ABORTED_PAYLOAD);
        if (response is json) {
            JobInfo|ConnectorError job = getJob(response);
            return job;
        } else {
            return response;
        }
    }

    # Get JSON delete batch information.
    #
    # + batchId - batch ID 
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function getBatchInfo(string batchId) returns @tainted BatchInfo|ConnectorError {
        json | ConnectorError response = self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id,
        <@untainted> BATCH, batchId]);
        if (response is json) {
            BatchInfo|ConnectorError batch = getBatch(response);
            return batch;
        } else {
            return response;
        }
    }

    # Get information of all batches of JSON delete operator job.
    #
    # + return - BatchInfo record if successful else ConnectorError occured
    public remote function getAllBatches() returns @tainted BatchInfo[]|ConnectorError {
        json|ConnectorError response = self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id,
            <@untainted> BATCH]);
        if (response is json) {
            BatchInfo[]|ConnectorError batchInfo = getBatchInfoList(response);
            return batchInfo;
        } else {
            return response;
        }
    }

    # Retrieve the JSON batch request.
    #
    # + batchId - batch ID
    # + return - JSON Batch request if successful else ConnectorError occured
    public remote function getBatchRequest(string batchId) returns @tainted json|ConnectorError {
        return self.httpBaseClient->getJsonRecord([<@untainted> JOB, self.job.id, <@untainted> BATCH, batchId, 
            <@untainted> REQUEST]);
    }

    # Get the results of the batch.
    #
    # + batchId - batch ID
    # + numberOfTries - number of times checking the batch state
    # + waitTime - time between two tries in ms
    # + return - Batch result as CSV if successful else ConnectorError occured
    public remote function getResult(string batchId, int numberOfTries = 1, int waitTime = 3000) 
        returns @tainted Result[]|ConnectorError {
        return checkBatchStateAndGetResults(getBatchPointer, getResultsPointer, self, batchId, numberOfTries, waitTime);
    }
};