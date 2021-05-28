<aura:application extends="force:slds">
    <aura:attribute name="QuoteId" type="String" default='false'/>
    <aura:attribute name="LoanerId" type="String" default='false'/>
    <aura:attribute name="LoanerExtId" type="String" default='false'/>
    <c:FinsarApprovalAppMasterComp QuoteId="{!v.QuoteId}" LoanerId="{!v.LoanerId}" LoanerExtId="{!v.LoanerExtId}"/>
</aura:application>