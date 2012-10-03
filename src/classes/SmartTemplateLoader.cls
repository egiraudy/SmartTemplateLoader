/*
Copyright (c) 2012, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
*/

global class SmartTemplateLoader /*implements Support.EmailTemplateSelector*/ {
    // Empty constructor
    global SmartTemplateLoader() {
    }
    // The main interface method
    global ID getDefaultEmailTemplateId(ID caseId) {
        // Select the case we're interested in, choosing any fields that are relevant to our decision
        Case c = [SELECT Status, Reason FROM Case WHERE Id=:caseId];
        
        Smart_Template_Loader_Conf__c conf = null;
        List<Smart_Template_Loader_Conf__c> confs = null;

        // get template from case status + case reason
        confs = [SELECT Template_Name__c FROM Smart_Template_Loader_Conf__c WHERE Case_Status__c = :c.status and Case_Reason__c = :c.reason];
        if (!confs.isEmpty()) {
            conf = confs[0];
            System.debug('got template: ' + conf.Template_Name__c);
        }

        // get template from case status
        if (conf==null) {
            confs = [SELECT Template_Name__c FROM Smart_Template_Loader_Conf__c WHERE Case_Status__c = :c.status];
            if (!confs.isEmpty()) {
                conf = confs[0];
                System.debug('got template: ' + conf.Template_Name__c);
            }
        }
        // get template from case reason
        confs = [SELECT Template_Name__c FROM Smart_Template_Loader_Conf__c WHERE Case_Reason__c = :c.reason];
        if (!confs.isEmpty()) {
            conf = confs[0];
            System.debug('got template: ' + conf.Template_Name__c);
        }

        // get default template 
        if (conf==null) {
            confs = [SELECT Template_Name__c FROM Smart_Template_Loader_Conf__c WHERE Case_Status__c = '' AND Case_Reason__c = ''];
            if (!confs.isEmpty()) {
                conf = confs[0];
                System.debug('got template: ' + conf.Template_Name__c);
            }
        }
        
        if (conf==null) {
            System.debug('no template!');
            return null;
        }
        
        // get the template ID
        List<EmailTemplate> ets = [SELECT id FROM EmailTemplate WHERE DeveloperName = :conf.Template_Name__c];
        //Return the ID of the template selected
        if (!ets.isEmpty()) {
            EmailTemplate et = ets[0];
            System.debug('template: ' + conf.Template_Name__c + ' -- id: ' + et.id);
            return et.id;
        }
        System.debug('No template with the name: ' + conf.Template_Name__c);
        
        return null;
    }
}