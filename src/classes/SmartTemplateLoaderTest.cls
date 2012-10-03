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

@isTest
private Class SmartTemplateLoaderTest {

    public static void createSetting(User u, String name, String template_name, String case_status, String case_reason) {
        System.runAs(u) {
            Smart_Template_Loader_Conf__c conf = new Smart_Template_Loader_Conf__c(
                    Name=name,
                    Case_Status__c=case_status,
                    Case_Reason__c=case_reason,
                    Template_Name__c=template_name
                    );
            insert conf;
        }
    }
    public static ID createTemplate(User u, String name) {
        EmailTemplate template = new EmailTemplate(
                FolderId = u.Id,
                TemplateType = 'text',
                DeveloperName = name,
                Name= 'Test name',
                Subject = 'Test Subject',
                Body = 'Hello This is test body',
                isActive=true);
        insert template;
        return template.id;
    }
    public static ID createCase(User u, String case_status, String case_reason) {
        Case thecase;
        System.runAs(u) {
            thecase = new Case(status=case_status,Origin='Email',reason = case_reason);
            insert thecase;
        }
        return thecase.id;
    }
    
    public static testmethod void testSmartLoader() {
        User u = [SELECT id,name FROM User WHERE id = :userInfo.getUserid()];
        ID t1 = createTemplate(u, 'template_new_ComplexFunctionality');
        ID t2 = createTemplate(u, 'template_new_ExistingProblem');
        ID t3 = createTemplate(u, 'template_escalated');
        ID t4 = createTemplate(u, 'template_default');

        createSetting(u, '1', 'template_new_ComplexFunctionality', 'New', 'Complex functionality');
        createSetting(u, '2', 'template_new_ExistingProblem', 'New', 'Existing problem');
        createSetting(u, '3', 'template_escalated', 'Escalated', '');
        createSetting(u, '4', 'template_default', '', '');
        createSetting(u, '5', 'fake_template', 'New', 'User didn\'t attend training');
        
        ID c1 = createCase(u, 'New', 'Complex functionality');
        ID c2 = createCase(u, 'New', 'Existing problem');
        ID c3 = createCase(u, 'Escalated', 'New problem');
        ID c4 = createCase(u, 'Waiting on customer', 'Instructions not clear');
        ID c5 = createCase(u, 'New', 'User didn\'t attend training');
        
        SmartTemplateLoader loader = new SmartTemplateLoader();
        
        ID res;
        res = loader.getDefaultEmailTemplateId(c1);
        System.assertEquals(true,res==t1);
        res = loader.getDefaultEmailTemplateId(c2);
        System.assertEquals(true,res==t2);
        res = loader.getDefaultEmailTemplateId(c3);
        System.assertEquals(true,res==t3);
        res = loader.getDefaultEmailTemplateId(c4);
        System.assertEquals(true,res==t4);
        res = loader.getDefaultEmailTemplateId(c5);
        System.assertEquals(true,res==null);
    }
}