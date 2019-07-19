<%@page import="com.jnj.CLA.model.InfoBean"%>
<%@page import="com.jnj.CLA.model.ReviewedCriteria"%>
<%@page import="com.jnj.CLA.model.DrugSummary"%>
<%@page import="java.text.MessageFormat"%>
<%@page import="com.jnj.CLA.model.EntityTypeSorter"%>
<%@page import="com.jnj.CLA.model.DataSorter"%>
<%@page import="java.io.IOException"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="org.apache.http.client.methods.CloseableHttpResponse"%>
<%@page import="org.apache.http.client.methods.HttpGet"%>
<%@page import="org.apache.http.client.protocol.HttpClientContext"%>
<%@page import="org.apache.http.impl.auth.DigestScheme"%>
<%@page import="org.apache.http.impl.client.BasicAuthCache"%>
<%@page import="org.apache.http.impl.client.HttpClients"%>
<%@page import="org.apache.http.client.AuthCache"%>
<%@page import="org.apache.http.impl.client.CloseableHttpClient"%>
<%@page import="org.apache.http.impl.client.BasicCredentialsProvider"%>
<%@page import="org.apache.http.auth.UsernamePasswordCredentials"%>
<%@page import="org.apache.http.auth.AuthScope"%>
<%@page import="org.apache.http.client.CredentialsProvider"%>
<%@page import="org.apache.http.HttpHost"%>
<%@page import="org.json.JSONArray"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.jnj.CLA.model.Criteria"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.jnj.CLA.model.Position"%>
<%@page import="com.jnj.CLA.model.EntityInfo"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
 pageEncoding="ISO-8859-1"%>
 <%@ page import="java.util.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">

<%
HashMap mapDrug = (HashMap)application.getAttribute("mapDrug");
System.out.println("mapDrug size>>>>>>>>>>>>"+mapDrug.size());
String role=(String)session.getAttribute("role");

String rowIndex=request.getParameter("rowIndex");
ArrayList drugSummaryList=(ArrayList)session.getAttribute("DrugSummaryList");
List jnjDrugListNew= new ArrayList();
if(drugSummaryList!=null && drugSummaryList.size()>0)
{
	for(int i=0;i<drugSummaryList.size();i++)
	{
		DrugSummary ds=  (DrugSummary)drugSummaryList.get(i);

		if(rowIndex.equalsIgnoreCase(ds.getReqId().toString()))
		{

			jnjDrugListNew.add(ds.getDrugCode().toUpperCase());
		}

	}

}


String reqId="";
String resText="";

String Title="";
//String AccessionNumber="";
String Author="";
String AuthorAffiliation="";
String BookTitle="";
//String CASRegistryNumber="";
String CandidateTerms="";
String ChemicalsBiochemicals="";
String CommonTerms="";
String ConceptCodes="";
String ConferenceInformation="";
//String DatabaseName="";
String DeviceIndexTerms="";
String DeviceManufacturer="";
String DeviceTradeName="";
String Diseases="";
String DrugManufacturer="";
String DrugTradeName="";
//String EmbaseSectionHeadings="";
String EmbaseSubjectHeadings="";
String GeneNames="";
String GeopoliticalLocations="";
//String ISSN="";
String Issue="";
String JournalName="";
String JournalTranslatedName="";
String Keyword="";
String MajorConcepts="";
String MethodsEquipment="";
String MiscellaneousDescriptors="";
String OrganismSupplementaryConcept="";
String Organisms="";
String PartsStructuresSystemsofOrganisms="";
String PublicationType="";
String OriginalTitle="";
String Status="";
String Synonyms="";
String ThematicGroups="";
String TripleSubheading="";
String Volume="";
String Year="";
String doi="";
String pages="";


String configPath = this.getServletContext().getRealPath("/");
System.out.println("configPath for LAT api----"+configPath);
configPath = configPath.substring(0, configPath.indexOf("LAT"));
System.out.println("Complete configPath  for LAT api----"+configPath);


Properties ConfigProps = new Properties();

ConfigProps.load(new FileInputStream(configPath+"/"+ "LAT.properties"));
System.out.println("loaded properties..");
String ovidRequestsUrl = ConfigProps.getProperty("ovidRequestsUrl");
String ovidRequestUser = ConfigProps.getProperty("ovidRequestUser");
String reviewedFeedbackUrl=ConfigProps.getProperty("reviewedFeedbackUrl");

String conclusion = "";
double prediction = 0;
String conclusionForIcsr = "";
ArrayList respTextList=new ArrayList();
JSONArray ovid = new JSONArray();
JSONArray revFeedback = new JSONArray();
JSONArray annotated = new JSONArray();
JSONArray classifier = new JSONArray();
JSONArray ensembleClassifier = new JSONArray();
JSONArray eneClassifier = new JSONArray();
JSONArray jnj_DrugArray = new JSONArray();
List jnj_DrugList=new ArrayList();
List conclusionList=new ArrayList();
JSONArray icsrExclusion = new JSONArray();
JSONArray icsrInclusion = new JSONArray();

ArrayList icsrExclusionList= new ArrayList();
ArrayList emptyExclusionList =new ArrayList();
ArrayList masterExclusionList =new ArrayList();
HashMap criteriaMap= new HashMap();

ArrayList icsrInclusionList= new ArrayList();
ArrayList emptyInclusionList =new ArrayList();
ArrayList masterInclusionList =new ArrayList();
HashMap inclusionCriteriaMap= new HashMap();


List entityList = new ArrayList();
List conceptNameList = new ArrayList();
List highlightList = new ArrayList();
List revHighlightList = new ArrayList();
List finalHighlightList = new ArrayList();
List xPositionList = new ArrayList();
List jnjDrugList= new ArrayList();
List revDrugList=new ArrayList();
List revTabList=new ArrayList();
List revEntityList=new ArrayList();
List revICSRList=new ArrayList();
List revCommentsList=new ArrayList();
List fullTextReviewList=new ArrayList();
List exReviewList=new ArrayList();
List inReviewList=new ArrayList();



	System.out.println("Started Rest services..");


	HttpHost target = new HttpHost("localhost", 8010, "http");
	CredentialsProvider credsProvider = new BasicCredentialsProvider();
	credsProvider.setCredentials(
	        new AuthScope(target.getHostName(), target.getPort()),
	        new UsernamePasswordCredentials("admin", "admin"));
	CloseableHttpClient httpclient = HttpClients.custom()
	        .setDefaultCredentialsProvider(credsProvider)
	        .build();

	String respStr = "";

	  AuthCache authCache = new BasicAuthCache();
	  DigestScheme digestAuth = new DigestScheme();
	  digestAuth.overrideParamter("realm", "some realm");
	  digestAuth.overrideParamter("nonce", "whatever");
	  authCache.put(target, digestAuth);

	  HttpClientContext localContext = HttpClientContext.create();
	  localContext.setAuthCache(authCache);


	  ovidRequestsUrl=ovidRequestsUrl+ovidRequestUser+"&rs:requestId="+rowIndex;
	  HttpGet httpget = new HttpGet(ovidRequestsUrl);
	  httpget.setHeader("Content-Type", "application/json");
	  try {
	  System.out.println("Else Executing request " + httpget.getRequestLine() + " to target " + target);
	      CloseableHttpResponse resp = httpclient.execute(target, httpget, localContext);
	      //CloseableHttpResponse resp2 = resp;
	      if (resp.getStatusLine().getStatusCode() != 200) {
	          System.out.println("Else Failed with Http error code::"+resp.getStatusLine().getStatusCode());
	        }else
	        {

	        	 BufferedReader brEntity = new BufferedReader(
		                        new InputStreamReader((resp.getEntity().getContent())));

	String outputEntity;
	String jsonTemp="";
	while ((outputEntity = brEntity.readLine()) != null) {
		//System.out.println("Response output JSON:::" + outputEntity.toString());
		jsonTemp=jsonTemp+outputEntity.toString();
	}
	JSONObject myResponse;
	myResponse = new JSONObject(jsonTemp);
	ovid=myResponse.getJSONArray("ovid");

	 if(ovid!=null && ovid.length()>0)
	{

		JSONObject myOvid = new JSONObject();
		myOvid = (JSONObject) ovid.getJSONObject(0);
		JSONObject annotEntity = new JSONObject();
		reqId= myOvid.getString("requestId");
	System.out.println("requestId from service::::"+reqId);
	resText=myOvid.getString("text");
	System.out.println("MY OVID ========>"+myOvid);

	/* if(myOvid.has("Accession Number") && myOvid.get("Accession Number")!=null)
		AccessionNumber=(String) myOvid.get("Accession Number"); */
	if(myOvid.has("Author") && myOvid.get("Author")!=null)
		Author=(String) myOvid.get("Author");
	if(myOvid.has("Author affiliation") && myOvid.get("Author affiliation")!=null)
		AuthorAffiliation=(String) myOvid.get("Author affiliation");
	if(myOvid.has("BookTitle") && myOvid.get("BookTitle")!=null)
		BookTitle=(String) myOvid.get("BookTitle");
	/* if(myOvid.has("CASRegistryNumber") && myOvid.get("CASRegistryNumber")!=null)
		CASRegistryNumber=(String) myOvid.get("CASRegistryNumber"); */
	if(myOvid.has("CandidateTerms") && myOvid.get("CandidateTerms")!=null)
		CandidateTerms=(String) myOvid.get("CandidateTerms");
	if(myOvid.has("ChemicalsBiochemicals") && myOvid.get("ChemicalsBiochemicals")!=null)
		ChemicalsBiochemicals=(String) myOvid.get("ChemicalsBiochemicals");
	if(myOvid.has("CommonTerms") && myOvid.get("CommonTerms")!=null)
		CommonTerms=(String) myOvid.get("CommonTerms");
	if(myOvid.has("ConceptCodes") && myOvid.get("ConceptCodes")!=null)
		ConceptCodes=(String) myOvid.get("ConceptCodes");
	if(myOvid.has("ConferenceInformation") && myOvid.get("ConferenceInformation")!=null)
		ConferenceInformation=(String) myOvid.get("ConferenceInformation");
	/* if(myOvid.has("Database name") && myOvid.get("Database name")!=null)
		DatabaseName=(String) myOvid.get("Database name"); */
	if(myOvid.has("DeviceIndexTerms") && myOvid.get("DeviceIndexTerms")!=null)
		DeviceIndexTerms=(String) myOvid.get("DeviceIndexTerms");
	if(myOvid.has("DeviceManufacturer") && myOvid.get("DeviceManufacturer")!=null)
		DeviceManufacturer=(String) myOvid.get("DeviceManufacturer");
	if(myOvid.has("DeviceTradeName") && myOvid.get("DeviceTradeName")!=null)
		DeviceTradeName=(String) myOvid.get("DeviceTradeName");
	if(myOvid.has("Diseases") && myOvid.get("Diseases")!=null)
		Diseases=(String) myOvid.get("Diseases");
	if(myOvid.has("DrugManufacturer") && myOvid.get("DrugManufacturer")!=null)
		DrugManufacturer=(String) myOvid.get("DrugManufacturer");
	if(myOvid.has("DrugTradeName") && myOvid.get("DrugTradeName")!=null)
		DrugTradeName=(String) myOvid.get("DrugTradeName");
	/* if(myOvid.has("EmbaseSectionHeadings") && myOvid.get("EmbaseSectionHeadings")!=null)
		EmbaseSectionHeadings=(String) myOvid.get("EmbaseSectionHeadings"); */
	if(myOvid.has("EmbaseSubjectHeadings") && myOvid.get("EmbaseSubjectHeadings")!=null)
		EmbaseSubjectHeadings=(String) myOvid.get("EmbaseSubjectHeadings");
	if(myOvid.has("GeneName") && myOvid.get("GeneName")!=null)
		GeneNames=(String) myOvid.get("GeneName");
	if(myOvid.has("GeopoliticalLocations") && myOvid.get("GeopoliticalLocations")!=null)
		GeopoliticalLocations=(String) myOvid.get("GeopoliticalLocations");
	/* if(myOvid.has("ISSN") && myOvid.get("ISSN")!=null)
		ISSN=(String) myOvid.get("ISSN"); */
	if(myOvid.has("Issue") && myOvid.get("Issue")!=null)
		Issue=(String) myOvid.get("Issue");
	if(myOvid.has("Journal name") && myOvid.get("Journal name")!=null)
		JournalName=(String) myOvid.get("Journal name");
	if(myOvid.has("JournalTranslatedName") && myOvid.get("JournalTranslatedName")!=null)
		JournalTranslatedName=(String) myOvid.get("JournalTranslatedName");
	if(myOvid.has("Keyword") && myOvid.get("Keyword")!=null)
		Keyword=(String) myOvid.get("Keyword");
	if(myOvid.has("MajorConcepts") && myOvid.get("MajorConcepts")!=null)
		MajorConcepts=(String) myOvid.get("MajorConcepts");
	if(myOvid.has("MethodsEquipment") && myOvid.get("MethodsEquipment")!=null)
		MethodsEquipment=(String) myOvid.get("MethodsEquipment");
	if(myOvid.has("MiscellaneousDescriptors") && myOvid.get("MiscellaneousDescriptors")!=null)
		MiscellaneousDescriptors=(String) myOvid.get("MiscellaneousDescriptors");
	if(myOvid.has("OrganismSupplementaryConcept") && myOvid.get("OrganismSupplementaryConcept")!=null)
		OrganismSupplementaryConcept=(String) myOvid.get("OrganismSupplementaryConcept");
	if(myOvid.has("Organisms") && myOvid.get("Organisms")!=null)
		Organisms=(String) myOvid.get("Organisms");
	if(myOvid.has("PartsStructuresSystemsofOrganisms") && myOvid.get("PartsStructuresSystemsofOrganisms")!=null)
		PartsStructuresSystemsofOrganisms=(String) myOvid.get("PartsStructuresSystemsofOrganisms");
	if(myOvid.has("Publication Type") && myOvid.get("Publication Type")!=null)
		PublicationType=(String) myOvid.get("Publication Type");
	if(myOvid.has("OriginalTitle") && myOvid.get("OriginalTitle")!=null)
		OriginalTitle=(String) myOvid.get("OriginalTitle");
	if(myOvid.has("Status") && myOvid.get("Status")!=null)
		Status=(String) myOvid.get("Status");
	if(myOvid.has("Synonyms") && myOvid.get("Synonyms")!=null)
		Synonyms=(String) myOvid.get("Synonyms");
	if(myOvid.has("ThematicGroups") && myOvid.get("ThematicGroups")!=null)
		ThematicGroups=(String) myOvid.get("ThematicGroups");
	if(myOvid.has("Title") && myOvid.get("Title")!=null)
		Title=(String) myOvid.get("Title");
	if(myOvid.has("TripleSubheading") && myOvid.get("TripleSubheading")!=null)
		TripleSubheading=(String) myOvid.get("TripleSubheading");
	if(myOvid.has("Volume") && myOvid.get("Volume")!=null)
		Volume=(String) myOvid.get("Volume");
	if(myOvid.has("Year") && myOvid.get("Year")!=null)
		Year=(String) myOvid.get("Year");
	if(myOvid.has("doi") && myOvid.get("doi")!=null)
		doi=(String) myOvid.get("doi");
	if(myOvid.has("Page") && myOvid.get("Page")!=null)
		pages=(String) myOvid.get("Page");
	 if(myOvid.has("classifier"))
    {

        ensembleClassifier = (JSONArray) myOvid.getJSONArray("classifier");
        conclusionForIcsr = (String)ensembleClassifier.getJSONObject(0).getString("conclusion");
    }
    else
    {
        ensembleClassifier = (JSONArray) myOvid.getJSONArray("classifier");
        conclusionForIcsr = (String)ensembleClassifier.getJSONObject(0).getString("conclusion");
    }

	 if(myOvid.has("classifier"))
	    {

		 if(ensembleClassifier.getJSONObject(0).has("drug_code_list"))

		 	jnj_DrugArray = (JSONArray)ensembleClassifier.getJSONObject(0).getJSONArray("drug_code_list");
	    }
	 if(jnj_DrugArray!=null && jnj_DrugArray.length()>0)
	 {
		 for(int i=0; i<jnj_DrugArray.length();i++)
		 {
		 System.out.println("ICSR YES::jnj_Drug::"+jnj_DrugArray.getString(i));
		 jnj_DrugList.add(jnj_DrugArray.getString(i).toUpperCase());
		 }
	 }else
	 {
		 System.out.println("jnj_Drug::All ICSR NO");
	 }
	System.out.println("Akash 1111---->"+jnjDrugListNew.size());

	 for(int i=0; i<jnjDrugListNew.size();i++)
	 {
		 System.out.println("Akash 22222---->"+jnjDrugListNew);
		 if(jnj_DrugList!=null && jnj_DrugList.size()>0 && jnj_DrugList.contains(jnjDrugListNew.get(i)))
		{
 			conclusionList.add("ICSR Yes");
		}else if((jnj_DrugList==null || jnj_DrugList.size()==0) && conclusionForIcsr.equalsIgnoreCase("ICSR Yes"))
		{
			conclusionList.add("ICSR Yes");
		}else if((jnj_DrugList==null || jnj_DrugList.size()==0) && conclusionForIcsr.equalsIgnoreCase("ICSR No"))
		{
			conclusionList.add("ICSR No");
		}else
			conclusionList.add("ICSR No");
	 }

	annotated = (JSONArray) myOvid.getJSONArray("annotated");
	classifier = (JSONArray) myOvid.getJSONArray("classifier");
	conclusion = (String)classifier.getJSONObject(0).getString("conclusion");
	/* JSONObject icsrVal=classifier.getJSONObject(0).getJSONObject("value");
	System.out.println("Reason Length::::"+icsrVal.getJSONArray("reason").length()); */
	prediction = classifier.getJSONObject(0).getDouble("prediction");
	if(myOvid.has("icsr_exclusions") && myOvid.getJSONArray("icsr_exclusions")!=null)
	{
	icsrExclusion=(JSONArray) myOvid.getJSONArray("icsr_exclusions");
	}
	if(myOvid.has("icsr_inclusions") && myOvid.getJSONArray("icsr_inclusions")!=null)
	{
	icsrInclusion=(JSONArray) myOvid.getJSONArray("icsr_inclusions");


	Position pos=new Position();
	for (int k = 0; k < annotated.length(); k++) {
		 annotEntity = new JSONObject();
		annotEntity = (JSONObject) annotated.getJSONObject(k);
		if(annotEntity.has("phrases") && annotEntity.getJSONArray("phrases")!=null)
		{
		for (int i = 0; i < annotEntity.getJSONArray("phrases").length(); i++) {
			JSONObject tempObj = new JSONObject();
			tempObj = annotEntity.getJSONArray("phrases").getJSONObject(i);
			for (int j = 0; j < tempObj.getJSONArray("entities").length(); j++) {
				JSONObject tempEntityObj = new JSONObject();
				if(tempObj.has("entities") && tempObj.getJSONArray("entities")!=null)
				{
				tempEntityObj = tempObj.getJSONArray("entities").getJSONObject(j);
				EntityInfo entityInfo = new EntityInfo();

				if(tempEntityObj.has("masterType") && tempEntityObj.getJSONArray("masterType")!=null)
				{

					JSONObject tempPosObj = new JSONObject();
					JSONArray posArray= new JSONArray();
					if(tempEntityObj.has("position") && tempEntityObj.getJSONArray("position")!=null)
					{
					posArray=tempEntityObj.getJSONArray("position");
					}
					pos=new Position();
					String conceptName="";
					if(tempEntityObj.has("conceptName") && tempEntityObj.getString("conceptName")!=null)
					{
						 conceptName=tempEntityObj.getString("conceptName");
						 conceptName=conceptName.replaceAll("[+^]*#$", "").trim();
					}

					String cui="";
					if(tempEntityObj.has("cui") && tempEntityObj.getString("cui")!=null)
					{
						 cui=tempEntityObj.getString("cui");
					}
					String score="";
					if(tempEntityObj.has("score") && tempEntityObj.getString("score")!=null)
					{
						score=tempEntityObj.getString("score");
					}
					String semType="";
					if(tempEntityObj.has("semType") && tempEntityObj.getString("semType")!=null)
					{
						semType=tempEntityObj.getString("semType");
					}

					String masterType=tempEntityObj.getJSONArray("masterType").toString();
					List mlist= new ArrayList();
					for(int p=0;p<tempEntityObj.getJSONArray("masterType").length();p++)
					mlist.add(tempEntityObj.getJSONArray("masterType").get(p).toString().trim());
				if(mlist.contains("AE"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
					pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
					pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
					//pos.setColor("red");
					pos.setColor("white1");
					 if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("purpul color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					}
					}
					if(!conceptNameList.contains(conceptName.trim()))
					{
					entityInfo.setEntityName(conceptName);
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.trim());
					}
				}else if(mlist.contains("Drug") && !mlist.contains("JnjDrug"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
					pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
					pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
					pos.setColor("blue");
					/* if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("blue color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					} */
					}

					if(!conceptNameList.contains(conceptName.trim()))
					{
					entityInfo.setEntityName(conceptName);
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.trim());
					}
				}else if(mlist.contains("Patient"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
						pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
						pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
						//pos.setColor("green");
						pos.setColor("white5");

					 if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("green color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					}
					}

					if(!conceptNameList.contains(conceptName.trim()))
					{
					entityInfo.setEntityName(conceptName.trim());
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.trim());
					}
				}else if(mlist.contains("Causal"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
					pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
					pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
					//pos.setColor("yellow");
					pos.setColor("white2");
					 if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("blue color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					}
					}

					if(!conceptNameList.contains(conceptName.trim()))
					{
					entityInfo.setEntityName(conceptName);
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.trim());
					}
				}else if(mlist.contains("Dose"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
					pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
					pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
					//pos.setColor("turquoise");
					pos.setColor("white3");

					 if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("turquoise color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					}
					}

					if(!conceptNameList.contains(conceptName.trim()))
					{
					entityInfo.setEntityName(conceptName);
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.trim());
					}
				}
				else if(mlist.contains("JnJDrug") || mlist.contains("JnjDrug"))
				{
					for(int n=0;n<posArray.length();n++)
					{
						pos=new Position();
					pos.setX(((JSONObject)posArray.get(n)).getInt("x"));
					pos.setY(((JSONObject)posArray.get(n)).getInt("y"));
					//pos.setColor("red");
					pos.setColor("white4");
					if(!xPositionList.contains(((JSONObject)posArray.get(n)).getInt("x")))
					{
						System.out.println("JSON pos.getX()"+((JSONObject)posArray.get(n)).getInt("x"));
						System.out.println("pos.getX()"+pos.getX());
						System.out.println("red color..");
						xPositionList.add(pos.getX());
						highlightList.add(pos);
					}
					}

					if(!conceptNameList.contains(conceptName.toUpperCase().trim()))
					{
					entityInfo.setEntityName(conceptName);
					jnjDrugList.add(conceptName.toUpperCase().trim());
					entityInfo.setMetaThesaurusId(cui);
					entityInfo.setPrecision(score);
					entityInfo.setEntityType(masterType);
					entityInfo.setSemType(semType);
					entityList.add(entityInfo);
					conceptNameList.add(conceptName.toUpperCase().trim());
					}
				}

			   }
			 }
			}

		}
	}
	}
	Collections.sort(highlightList, new DataSorter());
	//Collection.sort(highlightList, Comparator.comparing(Position::x));
	System.out.println("highlightList size:::"+highlightList.size());
	System.out.println("jnjDrugList size:::"+jnjDrugList.size());
	for(int i=0; i<highlightList.size();i++)
	{
	Position post=(Position)highlightList.get(i);

	}

	Collections.sort(entityList, new EntityTypeSorter());

	}
	}
	 resp.close();
	}
}catch (JSONException e) {
		// TODO Auto-generated catch block
		request.setAttribute("error", "serviceError");
		e.printStackTrace();
	}
catch (IOException e) {
	// TODO Auto-generated catch block
	request.setAttribute("error", "serviceError");
	e.printStackTrace();
}


	  reviewedFeedbackUrl=reviewedFeedbackUrl+rowIndex;
	  HttpGet httpget1 = new HttpGet(reviewedFeedbackUrl);
	  httpget1.setHeader("Content-Type", "application/json");

	  System.out.println("Else Executing view feedback request " + httpget1.getRequestLine() + " to target " + target);
	  try{
	      CloseableHttpResponse resp1 = httpclient.execute(target, httpget1, localContext);
	      //CloseableHttpResponse resp2 = resp;
	      if (resp1.getStatusLine().getStatusCode() != 200) {
	          System.out.println("Else Failed with Http error code::"+resp1.getStatusLine().getStatusCode());
	        }else
	        {

	        	 BufferedReader brEntity = new BufferedReader(
		                        new InputStreamReader((resp1.getEntity().getContent())));

				String outputEntity;
				String jsonTemp="";
				while ((outputEntity = brEntity.readLine()) != null) {
					//System.out.println("Response output JSON:::" + outputEntity.toString());
					jsonTemp=jsonTemp+outputEntity.toString();
				}
				JSONObject myResponse;
				myResponse = new JSONObject(jsonTemp);
				JSONObject jsFeedback;
				revFeedback=myResponse.getJSONArray("feedback");
				JSONObject reviewedFeedback = new JSONObject();
				Position pos=null;
				if(revFeedback!=null && revFeedback.length()>0)
				{
					for(int i=0; i<revFeedback.length();i++)
					{

						ReviewedCriteria exCtr=new ReviewedCriteria();
						ReviewedCriteria inCtr=new ReviewedCriteria();
						String e1="";
						String e2="";
						String e3="";
						String e4="";
						String e5="";
						String e6="";
						String e7="";
						String e8="";
						String e9="";
						String e10="";
						String e11="";
						String e12="";

						String i1="";
						String i2="";
						String i3="";
						String i4="";
						String i5="";
						String i6="";
						String i7="";
						String i8="";
						String i9="";


						jsFeedback=revFeedback.getJSONObject(i);
						String drug_cd="";
						if(jsFeedback.has("drug_cd") && jsFeedback.getString("drug_cd")!=null)
						{
							drug_cd= jsFeedback.getString("drug_cd");
							System.out.println("drug_cd::"+drug_cd);
							revDrugList.add(drug_cd);
						}
						if(jsFeedback.has("full_text_review") && jsFeedback.getString("full_text_review")!=null)
						{
							fullTextReviewList.add(jsFeedback.getString("full_text_review"));
						}
						if(jsFeedback.has("feedback") && jsFeedback.getJSONArray("feedback")!=null)
						{
							JSONArray feedbackArray=jsFeedback.getJSONArray("feedback");
							for(int j=0; j<feedbackArray.length();j++)
							{
								reviewedFeedback=(JSONObject)feedbackArray.get(j);

								if(reviewedFeedback.has("type") && reviewedFeedback.getString("type").equalsIgnoreCase("ICSR_Classification"))
								{
									String status="";
									String concl="";
									if((jnj_DrugList.contains(drug_cd) || (jnj_DrugList==null || jnj_DrugList.size()==0)) && conclusion.equalsIgnoreCase("ICSR Yes"))
									{
										concl="ICSR Yes";
									}else if((jnj_DrugList.contains(drug_cd) || (jnj_DrugList==null || jnj_DrugList.size()==0)) && conclusion.equalsIgnoreCase("ICSR No"))
									{
										concl="ICSR No";
									}
									else
									{
										concl="ICSR No";
									}
									if(reviewedFeedback.getString("user_feedback").equalsIgnoreCase("Accept") && concl.equalsIgnoreCase("ICSR Yes"))
									{
										status="icsrYes";
									}else if(reviewedFeedback.getString("user_feedback").equalsIgnoreCase("Reject") && concl.equalsIgnoreCase("ICSR Yes"))
									{
										status="icsrNo";
									}
									else if(reviewedFeedback.getString("user_feedback").equalsIgnoreCase("Accept") && concl.equalsIgnoreCase("ICSR No"))
									{
										status="icsrNo";
									}
									else if(reviewedFeedback.getString("user_feedback").equalsIgnoreCase("Reject") && concl.equalsIgnoreCase("ICSR No"))
									{
										status="icsrYes";
									}
									revICSRList.add(status);
								}

								if(reviewedFeedback.has("type") && reviewedFeedback.getString("type").equalsIgnoreCase("comments"))
								{
									revCommentsList.add(reviewedFeedback.getString("user_feedback"));
								}



									//System.out.println("type:::---::"+reviewedFeedback.getString("type"));
									if(reviewedFeedback.has("type"))
									{
										xPositionList=new ArrayList();
										if(reviewedFeedback.getString("type").equalsIgnoreCase("AE"))
										{

											/* if(!xPositionList.contains(reviewedFeedback.getInt("start_pos")))
											{ */
												xPositionList.add(reviewedFeedback.getInt("start_pos"));
												pos=new Position();
												pos.setX(reviewedFeedback.getInt("start_pos"));
												pos.setY(reviewedFeedback.getInt("end_pos")-reviewedFeedback.getInt("start_pos"));
												pos.setColor("purpul");
												pos.setDrugCode(drug_cd);
												revHighlightList.add(pos);
											//}
											//revHighlightList
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("JnJDrug"))
										{
											System.out.println("drug_cd::::::"+drug_cd);
											/* if(!xPositionList.contains(reviewedFeedback.getInt("start_pos")))
											{ */
												xPositionList.add(reviewedFeedback.getInt("start_pos"));
												pos=new Position();
												pos.setX(reviewedFeedback.getInt("start_pos"));
												pos.setY(reviewedFeedback.getInt("end_pos")-reviewedFeedback.getInt("start_pos"));
												pos.setColor("red");
												pos.setDrugCode(drug_cd);
												revHighlightList.add(pos);
											//}
											//revHighlightList
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Patient"))
										{
											/* if(!xPositionList.contains(reviewedFeedback.getInt("start_pos")))
											{ */
												xPositionList.add(reviewedFeedback.getInt("start_pos"));
												pos=new Position();
												pos.setX(reviewedFeedback.getInt("start_pos"));
												pos.setY(reviewedFeedback.getInt("end_pos")-reviewedFeedback.getInt("start_pos"));
												pos.setColor("green");
												pos.setDrugCode(drug_cd);
												revHighlightList.add(pos);
											//}
											//revHighlightList
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Causal"))
										{
											/* if(!xPositionList.contains(reviewedFeedback.getInt("start_pos")))
											{ */
												xPositionList.add(reviewedFeedback.getInt("start_pos"));
												pos=new Position();
												pos.setX(reviewedFeedback.getInt("start_pos"));
												pos.setY(reviewedFeedback.getInt("end_pos")-reviewedFeedback.getInt("start_pos"));
												pos.setColor("blue");
												pos.setDrugCode(drug_cd);
												revHighlightList.add(pos);
											//}
											//highlightList
										}
										//for exclusions

										if(reviewedFeedback.getString("type").equalsIgnoreCase("company_trial") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e1.equalsIgnoreCase(""))
												e1=e1+","+reviewedFeedback.getString("user_feedback");
											else
												e1=e1+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("metaanalysis") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e2.equalsIgnoreCase(""))
												e2=e2+","+reviewedFeedback.getString("user_feedback");
											else
												e2=e2+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("concomitant_drug") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e3.equalsIgnoreCase(""))
												e3=e3+","+reviewedFeedback.getString("user_feedback");
											else
												e3=e3+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("non_jnj_product") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e4.equalsIgnoreCase(""))
												e4=e4+","+reviewedFeedback.getString("user_feedback");
											else
												e4=e4+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("not_mah") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e5.equalsIgnoreCase(""))
												e5=e5+","+reviewedFeedback.getString("user_feedback");
											else
												e5=e5+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("in_vitro") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e6.equalsIgnoreCase(""))
												e6=e6+","+reviewedFeedback.getString("user_feedback");
											else
												e6=e6+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("incidental") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e7.equalsIgnoreCase(""))
												e7=e7+","+reviewedFeedback.getString("user_feedback");
											else
												e7=e7+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("no ade") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e8.equalsIgnoreCase(""))
												e8=e8+","+reviewedFeedback.getString("user_feedback");
											else
												e8=e8+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("no_patient") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e9.equalsIgnoreCase(""))
												e9=e9+","+reviewedFeedback.getString("user_feedback");
											else
												e9=e9+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("negative causality") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e10.equalsIgnoreCase(""))
												e10=e10+","+reviewedFeedback.getString("user_feedback");
											else
												e10=e10+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Review_Article") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e11.equalsIgnoreCase(""))
												e11=e11+","+reviewedFeedback.getString("user_feedback");
											else
												e11=e11+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Animal") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!e12.equalsIgnoreCase(""))
												e12=e12+","+reviewedFeedback.getString("user_feedback");
											else
												e12=e12+reviewedFeedback.getString("user_feedback");
										}
										//for inclusions
										if(reviewedFeedback.getString("type").equalsIgnoreCase("overdose") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i1.equalsIgnoreCase(""))
												i1=i1+","+reviewedFeedback.getString("user_feedback");
											else
												i1=i1+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("abuse_or_misuse") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i2.equalsIgnoreCase(""))
												i2=i2+","+reviewedFeedback.getString("user_feedback");
											else
												i2=i2+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Off_Label_Use") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i3.equalsIgnoreCase(""))
												i3=i3+","+reviewedFeedback.getString("user_feedback");
											else
												i3=i3+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Breastfeeding") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i4.equalsIgnoreCase(""))
												i4=i4+","+reviewedFeedback.getString("user_feedback");
											else
												i4=i4+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("Pregnancy") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i5.equalsIgnoreCase(""))
												i5=i5+","+reviewedFeedback.getString("user_feedback");
											else
												i5=i5+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("accidental_exposure") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i6.equalsIgnoreCase(""))
												i6=i6+","+reviewedFeedback.getString("user_feedback");
											else
												i6=i6+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("medication_error") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i7.equalsIgnoreCase(""))
												i7=i7+","+reviewedFeedback.getString("user_feedback");
											else
												i7=i7+reviewedFeedback.getString("user_feedback");
										}
										if(reviewedFeedback.getString("type").equalsIgnoreCase("lack_of_effect") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i8.equalsIgnoreCase(""))
												i8=i8+","+reviewedFeedback.getString("user_feedback");
											else
												i8=i8+reviewedFeedback.getString("user_feedback");

										}if(reviewedFeedback.getString("type").equalsIgnoreCase("transmission_issues") && reviewedFeedback.getString("operation").equalsIgnoreCase("Add"))
										{
											if(!i9.equalsIgnoreCase(""))
												i9=i9+","+reviewedFeedback.getString("user_feedback");
											else
												i9=i9+reviewedFeedback.getString("user_feedback");

										}
									}
							}


						}

						InfoBean ifb;
						List infoList=new ArrayList();
						if(!e1.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Company Sponsored Trial");
							ifb.setVal(e1);
							infoList.add(ifb);
						}
						if(!e2.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Meta-analysis");
							ifb.setVal(e2);
							infoList.add(ifb);
						}
						if(!e3.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Concomitant Med");
							ifb.setVal(e3);
							infoList.add(ifb);
						}
						if(!e4.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Non-JnJ Prod");
							ifb.setVal(e4);
							infoList.add(ifb);
						}
						if(!e5.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Not MAH");
							ifb.setVal(e5);
							infoList.add(ifb);
						}
						if(!e6.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("In Vitro");
							ifb.setVal(e6);
							infoList.add(ifb);
						}
						if(!e7.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Incidental");
							ifb.setVal(e7);
							infoList.add(ifb);
						}
						if(!e8.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("No ADE");
							ifb.setVal(e8);
							infoList.add(ifb);
						}
						if(!e9.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("No Patient");
							ifb.setVal(e9);
							infoList.add(ifb);
						}
						if(!e10.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("No/Negative causality");
							ifb.setVal(e10);
							infoList.add(ifb);
						}
						if(!e11.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Review Article");
							ifb.setVal(e11);
							infoList.add(ifb);
						}
						if(!e12.equalsIgnoreCase(""))
						{
							ifb= new InfoBean();
							ifb.setType("Animal");
							ifb.setVal(e12);
							infoList.add(ifb);
						}

						exCtr.setDrugCode(drug_cd);
						exCtr.setInfoList(infoList);
						exReviewList.add(exCtr);


						InfoBean ifb1;
						List infoList1=new ArrayList();
						if(!i1.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Overdose");
							ifb1.setVal(i1);
							infoList1.add(ifb1);
						}
						if(!i2.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Abuse or Misuse");
							ifb1.setVal(i2);
							infoList1.add(ifb1);
						}
						if(!i3.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Off Label Use");
							ifb1.setVal(i3);
							infoList1.add(ifb1);
						}
						if(!i4.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Breastfeeding");
							ifb1.setVal(i4);
							infoList1.add(ifb1);
						}
						if(!i5.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Pregnancy");
							ifb1.setVal(i5);
							infoList1.add(ifb1);
						}
						if(!i6.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Accidental Exposure");
							ifb1.setVal(i6);
							infoList1.add(ifb1);
						}
						if(!i7.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Medication Error");
							ifb1.setVal(i7);
							infoList1.add(ifb1);
						}
						if(!i8.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Lack of Effect");
							ifb1.setVal(i8);
							infoList1.add(ifb1);
						}
						if(!i9.equalsIgnoreCase(""))
						{
							ifb1= new InfoBean();
							ifb1.setType("Lack of Effect");
							ifb1.setVal(i9);
							infoList1.add(ifb1);
						}
						inCtr.setDrugCode(drug_cd);
						inCtr.setInfoList(infoList1);
						inReviewList.add(inCtr);
					}
				}

				if(jnjDrugListNew!=null && jnjDrugListNew.size()>0 && revDrugList!=null && revDrugList.size()>0)
				{
					for(int i=0; i<jnjDrugListNew.size(); i++)
					{
						System.out.println("jnjDrugListNew::"+jnjDrugListNew.get(i));
						for(int j=0; j<revDrugList.size(); j++)
						{
							System.out.println("revDrugList::"+revDrugList.get(j));
							if(jnjDrugListNew.get(i).toString().equalsIgnoreCase(revDrugList.get(j).toString()))
							{
								if(!revTabList.contains(i))
								revTabList.add(i);
							}
						}
					}

				}
				resp1.close();
			}
	  System.out.println("revDrugList size::"+revDrugList.size());
	  System.out.println("revTabList size::"+revTabList.size());
	  }catch (JSONException e) {
			// TODO Auto-generated catch block
			request.setAttribute("error", "serviceError");
			e.printStackTrace();
		}
	catch (IOException e) {
		// TODO Auto-generated catch block
		request.setAttribute("error", "serviceError");
		e.printStackTrace();
	}



/* Start ICSR Exclusion Criteria Implement */
emptyExclusionList.add("company_trial");
emptyExclusionList.add("metaanalysis");
emptyExclusionList.add("concomitant_drug");
emptyExclusionList.add("non_jnj_product");
emptyExclusionList.add("not_mah");
emptyExclusionList.add("in_vitro");
emptyExclusionList.add("incidental");
emptyExclusionList.add("no ade");
emptyExclusionList.add("no_patient");
emptyExclusionList.add("negative causality");
emptyExclusionList.add("Review_Article");
emptyExclusionList.add("Animal");
masterExclusionList.addAll(emptyExclusionList);

criteriaMap.put("company_trial","Company Sponsored Trial");
criteriaMap.put("metaanalysis","Meta-analysis");
criteriaMap.put("concomitant_drug","Concomitant Med");
criteriaMap.put("non_jnj_product","Non-JnJ Prod");
criteriaMap.put("not_mah","Not MAH");
criteriaMap.put("in_vitro","In Vitro");
criteriaMap.put("incidental","Incidental");
criteriaMap.put("no ade","No ADE");
criteriaMap.put("no_patient","No Patient");
criteriaMap.put("negative causality","No/Negative causality");
criteriaMap.put("Review_Article","Review Article");
criteriaMap.put("Animal","Animal");
criteriaMap.put("other","other");

/* if(icsrExclusion!=null && icsrExclusion.length()>0)
{
	System.out.println("icsrExclusion size:"+icsrExclusion.length());
	Criteria criteria= null;

for(int i=0; i<icsrExclusion.length(); i++)
{

	JSONObject icsrExc = new JSONObject();
	icsrExc = (JSONObject) icsrExclusion.getJSONObject(i);
	criteria= new Criteria();
	if(icsrExc.has("type") && icsrExc.getString("type")!=null)
	criteria.setCriteriaId(icsrExc.getString("type"));
	if(icsrExc.has("exclusion_status") && icsrExc.get("exclusion_status")!=null)
	criteria.setStatus((String)icsrExc.get("exclusion_status").toString());
	if(icsrExc.has("confidence_score") && icsrExc.get("confidence_score")!=null && !icsrExc.get("confidence_score").toString().equals("") && !"null".equalsIgnoreCase(icsrExc.get("confidence_score").toString()))
	{
	criteria.setConfidence(icsrExc.get("confidence_score").toString());
	}
	else
	criteria.setConfidence("");
	if(icsrExc.has("value") && icsrExc.getJSONArray("value")!=null && icsrExc.getJSONArray("value").length()>0)
	{
		String val="";
		List<String> list = new ArrayList<String>();
		for (int j=0; j<icsrExc.getJSONArray("value").length(); j++) {
		    list.add( icsrExc.getJSONArray("value").getString(j) );
		}if(list!=null && list.size()>0)
		{
			for(int k=0;k<list.size();k++)
			{
				if(list.size()==1)
				{
					val=list.get(k);
				}else
				{
					if(val.equalsIgnoreCase(""))
					{
						val=list.get(k);
					}else
					val=val+","+list.get(k);
				}
			}
		}
		criteria.setValue(val);
	}else

	criteria.setValue("");

	if(emptyExclusionList.contains(criteria.getCriteriaId()))
	{
		icsrExclusionList.add(criteria);
		emptyExclusionList.remove(criteria.getCriteriaId());
	}
}
} */
for(int i=0;i<emptyExclusionList.size(); i++)
{
	Criteria crit= new Criteria();
	crit.setCriteriaId((String)emptyExclusionList.get(i));
	crit.setConfidence("");
	crit.setValue("");
	icsrExclusionList.add(crit);
}
/* End ICSR Exclusion Criteria Implement */


/* Start ICSR Inclusion Criteria Implement */
emptyInclusionList.add("overdose");
emptyInclusionList.add("abuse_or_misuse");
emptyInclusionList.add("Off_Label_Use");
emptyInclusionList.add("Breastfeeding");
emptyInclusionList.add("Pregnancy");
emptyInclusionList.add("accidental_exposure");
emptyInclusionList.add("medication_error");
emptyInclusionList.add("lack_of_effect");
emptyInclusionList.add("transmission_issues");

masterInclusionList.addAll(emptyInclusionList);

inclusionCriteriaMap.put("overdose","Overdose");
inclusionCriteriaMap.put("abuse_or_misuse","Abuse/Misuse");
inclusionCriteriaMap.put("Off_Label_Use","Off-Label Use");
inclusionCriteriaMap.put("Breastfeeding","Breastfeeding");
inclusionCriteriaMap.put("Pregnancy","Pregnancy");
inclusionCriteriaMap.put("accidental_exposure","Accidental Exposure");
inclusionCriteriaMap.put("medication_error","Medication Error");
inclusionCriteriaMap.put("lack_of_effect","Lack of Effect");
inclusionCriteriaMap.put("transmission_issues","Transmission Issues");


/* if(icsrInclusion!=null && icsrInclusion.length()>0)
{
	Criteria criteria= null;

for(int i=0; i<icsrInclusion.length(); i++)
{

	JSONObject icsrInc = new JSONObject();
	icsrInc = (JSONObject) icsrInclusion.getJSONObject(i);
	criteria= new Criteria();
	if(icsrInc.has("type") && icsrInc.getString("type")!=null)
	criteria.setCriteriaId(icsrInc.getString("type"));
	if(icsrInc.has("inclusion_status") && icsrInc.get("inclusion_status")!=null)
	criteria.setStatus((String)icsrInc.get("inclusion_status").toString());
	if(icsrInc.has("confidence_score") &&  icsrInc.get("confidence_score")!=null && !icsrInc.get("confidence_score").toString().equals("") && !"null".equalsIgnoreCase(icsrInc.get("confidence_score").toString()))
	{
	criteria.setConfidence(icsrInc.get("confidence_score").toString());
	}
	else
	criteria.setConfidence("");
	if(icsrInc.has("value") && icsrInc.getString("value")!=null && !icsrInc.getString("value").toString().equals(""))
	{
		criteria.setValue(icsrInc.getString("value").toString());
	}else

	criteria.setValue("");

	if(emptyInclusionList.contains(criteria.getCriteriaId()))
	{
		icsrInclusionList.add(criteria);
		emptyInclusionList.remove(criteria.getCriteriaId());
	}
}
} */

for(int i=0;i<emptyInclusionList.size(); i++)
{
	Criteria crit= new Criteria();
	crit.setCriteriaId((String)emptyInclusionList.get(i));
	crit.setConfidence("");
	crit.setValue("");
	icsrInclusionList.add(crit);
}

/* End ICSR Inclusion Criteria Implement */


String userId = (String)session.getAttribute("userId");
if(userId==null)
	userId="User";

String flag = (String)request.getAttribute("flag");
String error = (String)request.getAttribute("error");

String scoreVal="";
DecimalFormat df = new DecimalFormat("#.###");
if(prediction>=0.75)
	scoreVal="High";
else if(prediction<0.75 && prediction>=0.50)
	scoreVal="Medium";
else if(prediction<0.50)
	scoreVal="Low";
prediction=prediction*100;

System.out.print(df.format(prediction));

System.out.println("conclusion-----"+conclusion);


if(flag==null || "".equals(flag)){
	flag = "";
}

String feedbackServiceUrl = ConfigProps.getProperty("feedbackServiceUrl");



%>

<html>
	<head>

		<title>J&amp;J - Autonomous Medical Memory Response</title>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<!-- Tell the browser to be responsive to screen width -->
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="">
		<meta name="author" content="">
		<link href="https://stackpath.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">
<link href="https://fonts.googleapis.com/css?family=Raleway:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i" rel="stylesheet">
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>

		<script type="text/javascript" src="js/lib/createjs-2015.05.21.min.js"></script>
		<script type="text/javascript" src="js/flow.min.js"></script>

		<script>

		var feedbackUrl='<%= feedbackServiceUrl %>';
		$(document).ready(function(){
		  $('[data-toggle="tooltip"]').tooltip();
		});
		</script>
		<!-- Favicon icon -->
	   	<link rel="icon" type="image/png" sizes="16x16" href="images/favicon.png">
		<!-- Bootstrap Core CSS -->
		<link href="css/lib/bootstrap/bootstrap.min.css" rel="stylesheet">
		<!-- <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"> -->
		<link href="css/style2.css" rel="stylesheet">
		<link href="css/styleNew.css" rel="stylesheet">
		<link href="css/jquery.highlight-within-textarea.css" rel="stylesheet">
		<link href="https://cdn.jsdelivr.net/npm/pretty-checkbox@3.0/dist/pretty-checkbox.min.css" rel="stylesheet">
		<script src="https://code.jquery.com/jquery-1.9.1.js"></script>
		<script src="js/jquery.highlight-within-textarea.js"></script>

		<script>
		var showBox="no";
		var sArr=[];
		var cStatus;
		var barDisplay;
		var mergeJson=[];
		//var reviewedTab=[];
		var reviewedTab = [<% for (int i = 0; i < revTabList.size(); i++) { %>"<%= revTabList.get(i) %>"<%= i + 1 < revTabList.size() ? ",":"" %><% } %>];
		var revICSRList= [<% for (int i = 0; i < revICSRList.size(); i++) { %>"<%= revICSRList.get(i) %>"<%= i + 1 < revICSRList.size() ? ",":"" %><% } %>];
		var revCommentsList= [<% for (int i = 0; i < revCommentsList.size(); i++) { %>"<%= revCommentsList.get(i) %>"<%= i + 1 < revCommentsList.size() ? ",":"" %><% } %>];
		var fullTextReviewList=[<% for (int i = 0; i < fullTextReviewList.size(); i++) { %>"<%= fullTextReviewList.get(i) %>"<%= i + 1 < fullTextReviewList.size() ? ",":"" %><% } %>];
		var   conclusionList=[<% for (int i = 0; i < conclusionList.size(); i++) { %>"<%= conclusionList.get(i) %>"<%= i + 1 < conclusionList.size() ? ",":"" %><% } %>];
		function showAll(tick, tab)
		{
			showJnj(tick, tab);
			showCausal(tick, tab);
			showAE(tick, tab);
			showDose(tick, tab);
			showPatient(tick, tab);
		}
		function showJnj(tick, tab)
		{
			var all=document.getElementById("respText"+tab).querySelectorAll(".red")
			if(tick==false)
				{
			for (var i = 0; i < all.length; i++) {

				all[i].className='white4';
			}
			}else if(tick==true)
				{
				var all=document.getElementById("respText"+tab).querySelectorAll(".white4")
				for (var i = 0; i < all.length; i++)
				{
					all[i].className='red';
				}
				}
		}
		function showCausal(tick, tab)
		{
			var all=document.getElementById("respText"+tab).querySelectorAll(".blue")
			if(tick==false)
				{
			for (var i = 0; i < all.length; i++) {

				all[i].className='white2';
			}
			}else if(tick==true)
				{
				var all=document.getElementById("respText"+tab).querySelectorAll(".white2")
				for (var i = 0; i < all.length; i++)
				{
					all[i].className='blue';
				}
				}
		}

		function showAE(tick, tab)
		{
			var all=document.getElementById("respText"+tab).querySelectorAll(".purpul")
			if(tick==false)
				{
			for (var i = 0; i < all.length; i++) {

				all[i].className='white1';
			}
			}else if(tick==true)
				{
				var all=document.getElementById("respText"+tab).querySelectorAll(".white1")
				for (var i = 0; i < all.length; i++)
				{
					all[i].className='purpul';
				}
				}
		}

		function showDose(tick, tab)
		{
			var all=document.getElementById("respText"+tab).querySelectorAll(".turquoise")
			if(tick==false)
				{
			for (var i = 0; i < all.length; i++) {

				all[i].className='white3';
			}
			}else if(tick==true)
				{
				var all=document.getElementById("respText"+tab).querySelectorAll(".white3")
				for (var i = 0; i < all.length; i++)
				{
					all[i].className='turquoise';
				}
				}
		}

		function showPatient(tick, tab)
		{
			var all=document.getElementById("respText"+tab).querySelectorAll(".green")
			if(tick==false)
				{
			for (var i = 0; i < all.length; i++) {

				all[i].className='white5';
			}
			}else if(tick==true)
				{
				var all=document.getElementById("respText"+tab).querySelectorAll(".white5")
				for (var i = 0; i < all.length; i++)
				{
					all[i].className='green';
				}
				}
		}

		function submitConfirmation(tab,jnjDrug) {
			var icsrType;
			if (document.getElementById('icsrYes'+tab).checked) {
				icsrType=document.getElementById('icsrYes'+tab).value;
				}
			if (document.getElementById('icsrNo'+tab).checked) {
				icsrType=document.getElementById('icsrNo'+tab).value;
				}


			 var conclusion=conclusionList[tab];
			 <%-- var conclusion='<%=conclusion%>'; --%>
			 var finVal="Accept";
			 var smileyVal="Accept";
			if(icsrType!=null)
			{
				if(conclusion==icsrType)
				{
				finVal="Accept";
				}
			else
				{
				finVal="Reject";
				}

			 if(reviewedTab.indexOf(tab)==-1)
			 {

			 reviewedTab.push(tab);

						document.getElementById("nav-"+tab+"-tab").className='nav-item nav-link reviewd-tab';

			var obj= {
					"type":"ICSR_Classification",
					"user_feedback":finVal
					};

					sArr.push(obj);
					submitFeedbackAjax(jnjDrug,tab);
			 }else
				 {
				 	topFunction();
					document.getElementById("msgId").innerHTML = "Already reviewed.";
					setTimeout(function ()
						{
							document.getElementById("msgId").innerHTML = "";
						}, 5000);
				 }
			}else
				{
				topFunction();
		    	document.getElementById("msgId").innerHTML = "Please select ICSR 'Yes' or 'No'.";
		    	setTimeout(function ()
		    			{
			    	    	document.getElementById("msgId").innerHTML = "";
			    		}, 5000);
				}
		}


		function submitFeedbackAjax(jnjDrug,tab) {

			var fullTextReview="No";
			if(document.getElementById("fulltext"+tab).checked==true){
				fullTextReview="Yes"
			}
			<%if((String)session.getAttribute("userId")!=null){%>
			 if(sArr!=null && sArr.length>0)
			    {
				var fdText="";
				fdText=document.getElementById('feedBack'+tab).value;
				var timeStamp = Math.floor(Date.now());
				var obj1= {
						"type":"userid",
						"user_feedback":'<%=userId %>',
						"timestamp":timeStamp
						};

				var obj2={
						"type":"comments",
						"user_feedback":fdText
						};


				mArr.push(obj2);

				if(sArr!=null && sArr.length>0)
				{
					for(var i=0;i<sArr.length;i++)
				    {
				    	mArr.push(sArr[i]);
				    }
				}

				if(arr!=null && arr.length>0)
				{
					for(var i=0;i<arr.length;i++)
				    {
				    	mArr.push(arr[i]);
				    }
				}

			    if(wsArr!=null && wsArr.length>0)
			    {
				    for(var i=0;i<wsArr.length;i++)
				    {
				    	mArr.push(wsArr[i]);
				    }
			    }

			    if(wsIncArr!=null && wsIncArr.length>0)
			    {
				    for(var i=0;i<wsIncArr.length;i++)
				    {
				    	mArr.push(wsArr[i]);
				    }
			    }

			    if(mIncArr!=null && mIncArr.length>0)
			    {
				    for(var i=0;i<mIncArr.length;i++)
				    {
				    	mArr.push(mIncArr[i]);
				    }
			    }

			    if(mArr!=null && mArr.length>0)
				{
				mArr.push(obj1);

				var feeddbackText2= {

						"feedback": mArr,
						"requestId": '<%= reqId%>',
						"drug_cd": jnjDrug,
						"full_text_review":fullTextReview
						};

				topFunction();
				var myJSON1 = JSON.stringify(feeddbackText2);
				console.log(myJSON1);
				  $.ajax({
					type: "POST",
					url: feedbackUrl,
					data: myJSON1,
					contentType: "application/json; charset=utf-8",
					dataType: "json",
					processData: true,
					success: function (data, status, jqXHR) {
					},
					error: function (xhr) {
						console.log("Error");
						console.log("Response::"+xhr.responseText);
					}
				});
				mergeJson.push(myJSON1);
				sArr=[];
				mArr=[];
				mIncArr=[];
				wsIncArr=[];
				wsArr=[];
				arr=[];
				mArr=[];
				topFunction()
				document.getElementById("msgId").innerHTML = "Selected drug reviewed successfully.";
				setTimeout(function ()
						{
							document.getElementById("msgId").innerHTML = "";
							if(reviewedTab.length=='<%=jnjDrugListNew.size()%>')
						    {
								submitReview('<%=jnjDrugListNew.size()%>');
							}
						}, 5000);
			}

			}
			else
				{
				topFunction();
				document.getElementById("msgId").innerHTML = "Please select ICSR 'Yes' or 'No'.";
				setTimeout(function ()
						{
							document.getElementById("msgId").innerHTML = "";
						}, 5000);
				}
			 <%}else{%>
			 window.location ='/LAT/login.jsp?msg=sessionExpire';
		 <%}%>
		}

		function submitReview(drugs)
		{

					window.open("drugCodeSummary.jsp?requestId=<%=rowIndex%>","_self");


		}


		function showInput(){
			 var x = document.getElementById('littext');

				if (x.style.display === 'none') {
					x.style.display = 'block';
					document.getElementById("addtext").innerHTML="Add Literature Texts &#9650;";
				} else {
					x.style.display = 'none';
					document.getElementById("addtext").innerHTML="Add Literature Texts &#9660;";
				}
			}


		</script>

	</head>
	<body onload="updateRevIndex('1')">
	<!-- Start NAVBAR -->
	<!--<nav class="navbar navbar-white ">
		<div class="brand">
			<img src="images/darkLogo.svg.png" alt="J&J Logo" class="img-responsive logo">
		</div>
		<div class="container-fluid">
			<div class="site-name">
				Literature Assist Tool
			</div>
		</div>
	</nav>-->
	<header id="header">
						<div class="container-fluid" style="padding-bottom:15px">

							<!-- Logo -->
								<a href="http://onesafetyai.qa.jnj.com:9100/LAT/drugCodeSummary.jsp" class="logo">
									<span class="symbol"><img src="images/logo.png" alt="" /></span><span class="title">One Safety AI Assistant <br/><font style="font-weight: normal;font-style: italic;font-size:8px;">Powered by J&J PVNLP Memory</font></span>
								</a>
								<div id="navbar3"  style="margin-right:240px;">
								Hello <%= userId %>

								<a href="drugCodeSummary.jsp"><i class="fa fa-home" aria-hidden="true"></i></a>
				<a href="login.jsp?msg=signout""><i class="fa fa-sign-out" aria-hidden="true" ></i></a>

				</div>
						</div>
					</header>
	<!-- END NAVBAR -->
	<div class="container-fluid">
	<% if(jnjDrugListNew!=null && jnjDrugListNew.size()>0)
									{
									System.out.println("jnjDrugList size--->"+jnjDrugListNew.size());
									%>
		<div class="row">
			<div class="col-sm-12">
				<form name="form2" action="drugCodeSummary.jsp">
					<input name="requestId" id="requestId" type="hidden" value="">

				<div class="card no-shadow main-card-width card-padd border-radius-0" id="pdftext" style="display:block;">
					<div class="card-body">
						<div style="background-color:#f7f7f7;">
							<label style="background-color:#f7f7f7" id="msgId"></label>
						</div>

				<div  id="accordion-style-1">
				<div class="mx-auto">
					<div class="accordion" id="accordionIndex">
						<div class="card">
							<div class="card-header" id="headingOne">
								<h5 class="mb-0">
							<button class="btn btn-link btn-block text-left" type="button" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
							<span class="clearfix imp-filed-title">
							<span class="field-value"><%=Title %></span>
							</span>
							</button>
						  </h5>
							</div>

							<div id="collapseOne" class="collapse  fade  show" aria-labelledby="headingOne" data-parent="#accordionIndex">
								<div class="card-body">
								<ul class="important-fields full-width">
									<%if(Author!=null && !Author.equals("")) {%>
									<li><label>Author:</label> <span class="field-value"><%=Author %></span></li>
									<%} %>
									<%-- <%if(AccessionNumber!=null && !AccessionNumber.equals("")) {%>
									<li><label>AccessionNumber:</label> <span class="field-value"><%=AccessionNumber %></span></li>
									<%} %> --%>
									<%if(AuthorAffiliation!=null && !AuthorAffiliation.equals("")) {%>
									<li><label>Author Affiliation:</label> <span class="field-value"><%=AuthorAffiliation %></span></li>
									<%} %>
									</ul>
									<ul class="important-fields">
									<%if(BookTitle!=null && !BookTitle.equals("")) {%>
									<li><label>Book Title:</label> <span class="field-value"><%=BookTitle %></span></li>
									<%} %>
									<%-- <%if(DatabaseName!=null && !DatabaseName.equals("")) {%>
									<li><label>Database Name:</label> <span class="field-value"><%=DatabaseName %></span></li>
									<%} %> --%>
									<%-- <%if(ISSN!=null && !ISSN.equals("")) {%>
									<li><label>ISSN:</label> <span class="field-value"><%=ISSN %></span></li>
									<%} %> --%>
									<%if(Issue!=null && !Issue.equals("")) {%>
									<li><label>Issue:</label> <span class="field-value"><%=Issue %></span></li>
									<%} %>
									<%if(JournalName!=null && !JournalName.equals("")) {%>
									<li><label>Journal Name:</label> <span class="field-value"><%=JournalName %></span></li>
									<%} %>
									<%if(JournalTranslatedName!=null && !JournalTranslatedName.equals("")) {%>
									<li><label>Journal Translated Name:</label> <span class="field-value"><%=JournalTranslatedName %></span></li>
									<%} %>
									<%if(PublicationType!=null && !PublicationType.equals("")) {%>
									<li><label>Publication Type:</label> <span class="field-value"><%=PublicationType %></span></li>
									<%} %>
									<%if(OriginalTitle!=null && !OriginalTitle.equals("")) {%>
									<li><label>Original Title:</label> <span class="field-value"><%=OriginalTitle %></span></li>
									<%} %>
									<%if(Status!=null && !Status.equals("")) {%>
									<li><label>Status:</label> <span class="field-value"><%=Status %></span></li>
									<%} %>
									<%if(Volume!=null && !Volume.equals("")) {%>
									<li><label>Volume:</label> <span class="field-value"><%=Volume %></span></li>
									<%} %>
									<%if(Year!=null && !Year.equals("")) {%>
									<li><label>Year:</label> <span class="field-value"><%=Year %></span></li>
									<%} %>
									<%if(doi!=null && !doi.equals("")) {%>
									<li><label>doi:</label> <span class="field-value"><%=doi %></span></li>
									<%} %>
									<%if(pages!=null && !pages.equals("")) {%>
									<li><label>Page:</label> <span class="field-value"><%=pages %></span></li>
									<%} %>
								</ul>
								</div>
							</div>
						</div>
					</div>
				</div>
				</div>
				<div class="index-section">
							<div class="panel-group">
							  <div class="panel panel-default">
								<div class="panel-heading">
								  <h4 class="panel-title">
									<a class="accordion-toggle" data-toggle="collapse" href="#index" aria-expanded="false" >Index</a>
								  </h4>
								</div>
								<div id="index" class="panel-collapse collapse">
								  <div class="panel-body index-content ">
									<ul class="index-list">
										<%if(ChemicalsBiochemicals!=null && !ChemicalsBiochemicals.equals("")) {%>
											<li><span class="index-label">Chemicals &amp; Biochemicals:</span><span><%=ChemicalsBiochemicals %></span></li>
										<%} %>
										<%if(ConceptCodes!=null && !ConceptCodes.equals("")) {%>
											<li><span class="index-label">Concept Codes:</span><span><%=ConceptCodes %></span></li>
											<%} %>
										<%if(ConferenceInformation!=null && !ConferenceInformation.equals("")) {%>
											<li><span class="index-label">Conference Information:</span><span><%=ConferenceInformation %></span></li>
											<%} %>
											<!-- <li><span class="index-label">Chemical Information:</span><span>Index Value here</span></li> -->
										<%if(CommonTerms!=null && !CommonTerms.equals("")) {%>
											<li><span class="index-label">Common Terms:</span><span><%=CommonTerms %></span></li>
											<%} %>
										<%if(CandidateTerms!=null && !CandidateTerms.equals("")) {%>
											<li><span class="index-label">Candidate Terms:</span><span><%=CandidateTerms %></span></li>
											<%} %>
										<%if(DeviceManufacturer!=null && !DeviceManufacturer.equals("")) {%>
											<li><span class="index-label">Device Manufacturer:</span><span><%=DeviceManufacturer %></span></li>
											<%} %>
										<%if(Diseases!=null && !Diseases.equals("")) {%>
											<li><span class="index-label">Diseases:</span><span><%=Diseases %></span></li>
											<%} %>
										<%if(DeviceTradeName!=null && !DeviceTradeName.equals("")) {%>
											<li><span class="index-label">Device Trade Name:</span><span><%=DeviceTradeName %></span></li>
											<%} %>
										<%-- <%if(EmbaseSectionHeadings!=null && !EmbaseSectionHeadings.equals("")) {%>
											<li><span class="index-label">Embase Section Headings:</span><span><%=EmbaseSectionHeadings %></span></li>
											<%} %> --%>
										<%if(GeopoliticalLocations!=null && !GeopoliticalLocations.equals("")) {%>
											<li><span class="index-label">Geopolitical Locations:</span><span><%=GeopoliticalLocations %></span></li>
											<%} %>
										<%if(GeneNames!=null && !GeneNames.equals("")) {%>
											<li><span class="index-label">Gene Name:</span><span><%=GeneNames %></span></li>
											<%} %>
										<%if(Keyword!=null && !Keyword.equals("")) {%>
											<li><span class="index-label">Keyword:</span><span><%=Keyword %></span></li>
											<%} %>
										<%if(MajorConcepts!=null && !MajorConcepts.equals("")) {%>
											<li><span class="index-label">Major Concepts:</span><span><%=MajorConcepts %></span></li>
											<%} %>
										<%if(DrugManufacturer!=null && !DrugManufacturer.equals("")) {%>
											<li><span class="index-label">Drug Manufacturer:</span><span><%=DrugManufacturer %></span></li>
											<%} %>
											<!-- <li><span class="index-label">Linked Terms:</span><span>Index Value here</span></li> -->
										<%if(MiscellaneousDescriptors!=null && !MiscellaneousDescriptors.equals("")) {%>
											<li><li><span class="index-label">Miscellaneous Descriptors:</span><span><%=MiscellaneousDescriptors %></span></li>
											<%} %>
										<%if(MethodsEquipment!=null && !MethodsEquipment.equals("")) {%>
											<li><span class="index-label">Methods &amp; Equipment:</span><span><%=MethodsEquipment %></span></li>
											<%} %>
										<%if(DeviceIndexTerms!=null && !DeviceIndexTerms.equals("")) {%>
											<li><span class="index-label">Device Index Terms:</span><span><%=DeviceIndexTerms %></span></li>
											<%} %>
										<%if(Organisms!=null && !Organisms.equals("")) {%>
											<li><span class="index-label">Organisms:</span><span><%=Organisms %></span></li>
											<%} %>
										<%if(OrganismSupplementaryConcept!=null && !OrganismSupplementaryConcept.equals("")) {%>
											<li><span class="index-label">Organism Supplementary Concept:</span><span><%=OrganismSupplementaryConcept %></span></li>
											<%} %>

										<%if(PartsStructuresSystemsofOrganisms!=null && !PartsStructuresSystemsofOrganisms.equals("")) {%>
											<li><span class="index-label">Parts, Structures &amp; Systems of Organisms:</span><span><%=PartsStructuresSystemsofOrganisms %></span></li>
											<%} %>
											<!-- <li><span class="index-label">Profile Section:</span><span>Index Value here</span></li> -->
										<%-- <%if(CASRegistryNumber!=null && !CASRegistryNumber.equals("")) {%>
											<li><span class="index-label">CAS Registry Number:</span><span><%=CASRegistryNumber %></span></li>
											<%} %> --%>
										<%if(EmbaseSubjectHeadings!=null && !EmbaseSubjectHeadings.equals("")) {%>
											<li><span class="index-label">Embase Subject Headings: </span><span><%=EmbaseSubjectHeadings %></span></li>
											<%} %>
											<!-- <li><span class="index-label">Subject Heading:</span><span>Index Value here</span></li> -->
										<%if(Synonyms!=null && !Synonyms.equals("")) {%>
											<li><span class="index-label">Synonyms:</span><span><%=Synonyms %></span></li>
											<%} %>
										<%if(ThematicGroups!=null && !ThematicGroups.equals("")) {%>
											<li><span class="index-label">Thematic Groups:</span><span><%=ThematicGroups %></span></li>
											<%} %>
										<%if(DrugTradeName!=null && !DrugTradeName.equals("")) {%>
											<li><span class="index-label">Drug Trade Name:</span><span><%=DrugTradeName %></span></li>
											<%} %>
											<!-- <li><span class="index-label">Taxa Notes:</span><span>Index Value here</span></li> -->
										<%if(TripleSubheading!=null && !TripleSubheading.equals("")) {%>
											<li><span class="index-label">Triple Subheading:</span><span><%=TripleSubheading %></span></li>
											<%} %>
									</ul>
								  </div>
								</div>
							  </div>
							</div>
						</div>

						<div class="edit-post-sec">

							<div class="top-sec">
								<div class="reviewing-sec">
								<% int n=1; %>
									<div class="rev-counter">Drug <span id="revInd"></span> of <%=jnjDrugListNew.size() %></div>


								<div class="drug-tab">
									<nav>
										<div class="nav nav-tabs" id="nav-tab" role="tablist">
										<%for(int i=0;i<jnjDrugListNew.size();i++){
											String val="test";
											if(mapDrug.get(jnjDrugListNew.get(i))!=null)
												val=mapDrug.get(jnjDrugListNew.get(i)).toString();
											if(i==0){
											%>
											<a  class="nav-item nav-link active" id="nav-<%=i %>-tab" data-toggle="tab" href="#nav-<%=i %>" role="tab" aria-controls="nav-<%=i%>" aria-selected="true" onclick="updateRevIndex('<%=i+1 %>')"><div class="toltipNav"><%=jnjDrugListNew.get(i) %><span class="toltiptext"><span class="toltipNav-body"><%=val %></span></span>
											</div></a>


											<%}else if(i>=1){ %>
											<a  class="nav-item nav-link" id="nav-<%=i %>-tab" data-toggle="tab" href="#nav-<%=i %>" role="tab" aria-controls="nav-<%=i %>" aria-selected="false" onclick="updateRevIndex('<%=i+1 %>')">
											<div class="toltipNav"><%=jnjDrugListNew.get(i) %>
											<span class="toltiptext"><span class="toltipNav-body"><%=val %></span></span></div>
											</a>
											<%} %>
										<%} %>
										</div>
									</nav>
								</div>
								</div>
							</div>
							<!--  End Iteration2 for Legend -->



							 <div class="tab-content" id="nav-tabContent">
							 <% for(int i=0; i<jnjDrugListNew.size();i++) {

							 %>

							<%if(i==0)
							 { %>
                            <div class="tab-pane fade show active" id="nav-<%=i %>" role="tabpanel" aria-labelledby="nav-<%=i %>-tab">
                            	<div class="pull-right">
										<label class="fancy-checkbox">
										<input id="fulltext<%=i%>" type="checkbox" >
										<span>Need Full Text</span>
										</label>
									</div>
                            <%} else{ %>
                            <div class="tab-pane fade " id="nav-<%=i %>" role="tabpanel" aria-labelledby="nav-<%=i %>-tab">
                            	<div class="pull-right full-text">
										<label class="fancy-checkbox">
										<input id="fulltext<%=i%>" type="checkbox" >
										<span>Need Full Text</span>
										</label>
									</div>
                            <%} %>
                             <div><span id="toltipInc<%=i %>" class="test" >
										<%
										if(revTabList!=null && revTabList.size()>0){
											for(int j=0; j<revTabList.size(); j++)
											{
												if(revTabList.get(j).equals(i))
												{ %>

													<%for(int k=0; k<exReviewList.size();k++)
													{
														ReviewedCriteria rCriteria=(ReviewedCriteria)exReviewList.get(k);
														if(jnjDrugListNew.get(i).toString().equalsIgnoreCase(rCriteria.getDrugCode()))
																{
																	for(int m=0; m<rCriteria.getInfoList().size();m++)
																	{

																	InfoBean rec=(InfoBean)rCriteria.getInfoList().get(m);
																	%>
																	<div  class='toltipExc' ><%=rec.getType()%><span class='toltiptext'><span class='toltip-body'><b>Value : </b><%=rec.getVal() %></span></span></div>
															<%  	}

																}
													}%>
													<br>
												<%	for(int k=0; k<inReviewList.size();k++)
													{
														ReviewedCriteria rCriteria=(ReviewedCriteria)inReviewList.get(k);
														if(jnjDrugListNew.get(i).toString().equalsIgnoreCase(rCriteria.getDrugCode()))
																{
																	for(int m=0; m<rCriteria.getInfoList().size();m++)
																	{

																	InfoBean rec=(InfoBean)rCriteria.getInfoList().get(m);
																	%>
																	<div  class='toltipInc' ><%=rec.getType()%><span class='toltiptext'><span class='toltip-body'><b>Value : </b><%=rec.getVal() %></span></span></div>
															<%  	}

																}
													}

													%>

										<%		}
										}}
										%></span>
										<div id="icsrIncId" class="inclusion-category"></div>
										<br>
										 <div id="icsrId" class="exclusion-category"></div>
							</div>
							<script>
									var excArr=[];
									var remArr=[];
									var incArr=[];
									var remIncArr=[];
								</script>
							<script>


										function populateIncCriteria()
										{
										document.getElementById("icsrIncId").innerHTML="";
										for(var n=0;n<incArr.length;n++)
											{
												if(incArr[n].value!="")
													{
													 document.getElementById("icsrIncId").innerHTML = document.getElementById("icsrIncId").innerHTML +
													"<div class='toltipInc'>"+incArr[n].name+"<span class='toltiptext'><span class='toltip-body'><b>Value : </b>"+incArr[n].value +"</span></span></div>";
													}
											}
										}

										populateIncCriteria();

										function populateCriteria()
										{
										document.getElementById("icsrId").innerHTML="";
										for(var n=0;n<excArr.length;n++)
											{
												if(excArr[n].value!="")
													{
													 document.getElementById("icsrId").innerHTML = document.getElementById("icsrId").innerHTML +
													"<div class='toltipExc'>"+excArr[n].name+"<span class='toltiptext'><span class='toltip-body'><b>Value : </b>"+excArr[n].value +"</span></span></div>";
													}
											}
										}

										populateCriteria();
										</script>
                      	<div class="complete-change">

								 <div class="mylegend">
			<div class="panel-group accordian" id="accordion">
			  <div class="panel">
				<div class="panel-heading">
				<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapse1<%=i%>">
					Legend</a>
				</div>

				<div id="collapse1<%=i%>" class="panel-collapse collapse show">
				  <div class="panel-body">
					<ul class="my-legend-list">
					<%if(role!=null && role.equalsIgnoreCase("supervisor"))
					{%>
						<li>
							<label class="fancy-checkbox">
								<input id="chkId<%=i %>" type="checkbox"  onclick="showAll(this.checked, '<%=i %>')" >
								<span>Select All</span>
							</label>
						</li>
					<%}%>


						<li>
							<div class="legend-text">
							<label class="legend-checkbox">
							<input id="chkId1<%=i %>" type="checkbox"  onclick="showAE(this.checked, '<%=i %>')" >
								<span class="purpul rectangle"></span> AE
								</label>
							</div>
						</li>


						<%-- <li>
							<div class="legend-text">
							<label class="legend-checkbox">
							<input id="chkId3<%=i %>" type="checkbox"  onclick="showDose(this.checked, '<%=i %>')" >
								<span class="turquoise rectangle"></span>Dose
								</label>
							</div>
						</li> --%>

						<li>
							<div class="legend-text">
							<label class="legend-checkbox">
							<input id="chkId4<%=i %>" type="checkbox"  onclick="showJnj(this.checked, '<%=i %>')" >
								<span class="red rectangle"></span>JnJ Drug
								</label>
							</div>
						</li>


						<li>

							<div class="legend-text">
							<label class="legend-checkbox">
							<input id="chkId5<%=i %>" type="checkbox"  onclick="showPatient(this.checked, '<%=i %>')" >
								<span class="green rectangle"></span> Patient
								</label>
							</div>
						</li>
						<li class="seperator">
						</li>
						<li class="no-event">
							<div class="legend-text">
							<label class="legend-checkbox">
								<input id="chkId2<%=i %>" type="checkbox"  onclick="showCausal(this.checked, '<%=i %>')" >
								<span class="blue rectangle"></span>Causal attribution
								</label>
							</div>
						</li>

						<li  class="no-event">
							<div class="legend-text">
							<label class="legend-checkbox">
							<input type="checkbox" >
								<span class="square" style="background-color:#ffc107;"></span>ICSR Exclusions
								</label>
							</div>
						</li>
						<li class="no-event">
							<div class="legend-text">
							<label class="legend-checkbox">
							<input type="checkbox" >
								<span class="square" style="background-color: #5cb85c;"></span>ICSR Inclusions
								</label>
							</div>
						</li>
					</ul>
					<%if(role==null || !role.equalsIgnoreCase("supervisor"))
					{%>
					<script>
					 document.getElementById('chkId1<%=i%>').disabled=true;
					 document.getElementById('chkId2<%=i%>').disabled=true;
					 document.getElementById('chkId4<%=i%>').disabled=true;
					 document.getElementById('chkId5<%=i%>').disabled=true;

					 </script>
					<%} %>

				  </div>
				</div>
			  </div>

			  <div class="panel">
				<div class="panel-heading">
				  <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapse2<%=i%>">
					Action</a>
				</div>

				<div id="collapse2<%=i%>" class="panel-collapse collapse show">
				  <div class="panel-body">
				  	<ul class="actionable-item">

						<li class="icsr-block shield-anchor">
							<label class="fancy-radio">
								<input name="icsrButt<%=i %>" id="icsrYes<%=i %>" value="ICSR Yes" type="radio" onchange="displayBox('ICSR Yes','<%=i%>');"/>
								<span><i></i>ICSR Yes</span>
							</label>
							<%if(role!=null && role.equalsIgnoreCase("supervisor"))
								{%>
							<span class="shield-tag"><span onclick="displayChart('<%=i%>','<%=conclusionForIcsr %>');"><img src="images/robote.gif"></span> Ask LAT</span>
							<%} %>
						</li>
						<li class="shield-anchor">
							<label class="fancy-radio">
								<input name="icsrButt<%=i %>" id="icsrNo<%=i %>" value="ICSR No" type="radio" onchange="displayBox('ICSR No','<%=i%>');"/>
								<span><i></i>ICSR No</span>
							</label>
						</li>

						</li>

					</ul>
				  </div>
				</div>
			  </div>

			  <div class="panel">
				<div class="panel-heading">
				  <a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapse3<%=i%>">
					Notes</a>
				</div>

				<div id="collapse3<%=i%>" class="panel-collapse collapse show">
				  <div class="panel-body">
					<div class="comment-box">
						<textarea id="feedBack<%=i %>" name="feedBack" placeholder="Notes" rows="2" max-rows="4" class="form-control"></textarea>
					</div>
					<div class="main-btn"> <div class="btn-review"><button type="button" id="reviewId<%=i%>" class="btn btn-custome " onclick="submitConfirmation('<%=i%>','<%=jnjDrugListNew.get(i)%>');">Review <%=jnjDrugListNew.get(i)%></button></div> </div>
				  </div>
				</div>
			  </div>
		</div>
		</div>
								<div id="respText<%=i%>" ></div>

									<script>
										var respText;
										var str='';
										var lastY=0;
										var dcode='<%=jnjDrugListNew.get(i)%>';
										<% if(resText!=null && resText.length()>0 )
										{
											String modText=resText.replace("'", "\\'");
											modText=modText.replace("<ovid:br/>", "");
											%>
											respText='<%=modText%>';
										var eop= '<%= resText.length() %>';
										<%
											if(revTabList.contains(i))
											{
												Collections.sort(revHighlightList, new DataSorter());
												finalHighlightList=revHighlightList;
												if(role!=null && role.equalsIgnoreCase("supervisor"))
												{%>
												document.getElementById('chkId<%=i%>').disabled=true;
												<%}%>
												document.getElementById('chkId1<%=i%>').disabled=true;
												document.getElementById('chkId2<%=i%>').disabled=true;
												document.getElementById('chkId4<%=i%>').disabled=true;
												document.getElementById('chkId5<%=i%>').disabled=true;
												document.getElementById('feedBack<%=i %>').disabled=true;
												document.getElementById('icsrYes<%=i %>').disabled=true;
												document.getElementById('icsrNo<%=i %>').disabled=true;
												document.getElementById('reviewId<%=i %>').disabled=true;
												document.getElementById('fulltext<%=i%>').disabled=true;

												<%
											}else
											{
											finalHighlightList=highlightList;
											}

										if(finalHighlightList!=null && finalHighlightList.size()>0)
										{
											System.out.println("In JSP highlightList size::"+finalHighlightList.size());
										for(int j=0; j<finalHighlightList.size();j++)
											{
											Position pos=(Position)finalHighlightList.get(j); %>

											var x=<%=pos.getX()%>;
											var y=<%=pos.getY()%>;
											var drugCode='<%= pos.getDrugCode()%>';
											var color='<%=pos.getColor()%>';
											if(lastY<=x)
												{
											str=str+respText.substring(lastY,x);
												}
										<%	if(j==0)
												{
											%>
											<%-- if(chkId<%=i%>.checked==true)
												{ --%>

													str=str+"<span class='"+color+"'>"+respText.substring(x,x+y)+"</span>";

												/* }else{
													str=str+"<span class='white'>"+respText.substring(x,x+y)+"</span>";
												} */
											<%	}
											else
												{ %>
													var c= eval(x+y);
													<%-- if(chkId<%=i%>.checked==true)
													{ --%>

													str=str+"<span class='"+color+"'>"+respText.substring(x,x+y)+"</span>";

													/* }else{
														str=str+"<span class='white'>"+respText.substring(x,x+y)+"</span>";
													} */
										<%		} %>

												lastY=x+y;
											<%}
										}
										%>
											str=str+respText.substring(lastY,eop);
											document.getElementById("respText<%=i%>").innerHTML=str;
										<%} %>
									</script>

								<script src="js/autosize.min.js"></script>
								<script type="text/javascript">autosize(document.getElementById("mytext"));</script>


						<div id="results1" class="clearfix">
								<div id="icsrResults<%=i%>" class="myresult" align="center" >
								<div class="row">
								<div class="col-sm-12">





 											<div id="rsummary1<%=i %>" class="highlite-box rsummary1<%=i %>" style="display:none">
												<div class="c-image"> <img src="images/image002.png"></div>
												<div class="highlight-one">Hi <%=userId %>! I am still learning and I might be wrong but at this moment I feel that this reference might have a safety case <span class="icsrvalue"><%=conclusionList.get(i) %></span>  with <div class="toltip"><%=scoreVal %><span class="toltiptext"><span class="toltip-body"><%=df.format(prediction) %></span></span></div> confidence; because it has our drug named JNJ drug which seems to have causal attribution to the drug. Off course there is mention of patients.</div>
												<div style="display:none" class="highlight-two">Along with this I also found exclusion criteria as  <span class="icsrId1<%=i%>" id="icsrId1<%=i%>"></span> and inclusions criteria as <span id="icsrIncId1<%=i%>"></span> which may need your review.</div>
											</div>

											<div  id="rsummary2<%=i %>" class="highlite-box rsummary2<%=i %>" style="display:none">
												<div class="c-image"> <img src="images/image004.png"></div>
												<div class="highlight-one">Hey <%=userId %>, Okay- again I might be wrong but I feel the above reference might be a valid safety case <span class="icsrvalue"><%=conclusionList.get(i) %></span>  with <div class="toltip"><%=scoreVal %><span class="toltiptext"><span class="toltip-body"><%=df.format(prediction) %></span></span></div> confidence.This reference has the  J&J drug  which seem to be related.</div>
												<div style="display:none" class="highlight-two">Further, I found exclusion criteria as <span class="icsrId<%=i%>" id="icsrId2<%=i%>"></span> and inclusions criteria as <span id="icsrIncId2<%=i%>"></span> that may need your review.</div>
											</div>

											<div id="rsummary3<%=i %>" class="highlite-box rsummary3<%=i %>" style="display:none">
												<div class="c-image"> <img src="images/image005.png"></div>
												<div class="highlight-one">Hi <%=userId %>! This seems to be <span class="icsrvalue"><%=conclusionList.get(i) %></span>  with <div class="toltip"><%=scoreVal %><span class="toltiptext"><span class="toltip-body"><%=df.format(prediction) %></span></span></div> confidence</div>
												<div style="display:none" class="highlight-two">However there are exclusion criteria as <span class="icsrId<%=i%>" id="icsrId3<%=i%>"></span> and Special condition as <span id="icsrIncId3<%=i%>"></span> that are been detected and may need your review.</div>
											</div>

											<div id="rsummary4<%=i %>" class="highlite-box rsummary4<%=i %>" style="display:none">
												<div class="c-image"> <img src="images/image007.png"></div>
												<div class="highlight-one">Hmmmm.... apologies! I am still learning but I feel there is a valid  <span class="icsrvalue"><%=conclusionList.get(i) %></span>  with <div class="toltip"><%=scoreVal %><span class="toltiptext"><span class="toltip-body"><%=df.format(prediction) %></span></span></div> confidence</div>
												<div style="display:none" class="highlight-two">However there are exclusion criteria as <span class="icsrId<%=i%>" id="icsrId4<%=i%>"></span> and Special condition as <span id="icsrIncId4<%=i%>"></span> that are been detected and Your feedback is highly appreciated!</div>
											</div>

											<div id="rsummaryNo1<%=i %>" class="highlite-box rsummaryNo1<%=i %>" style="display:none">
												<div class="c-image"> <img src="images/image002.png"></div>
												<div class="highlight-one">Hi <%=userId %>! I am still learning and I might be wrong but at this moment I feel that this reference might have a safety case <span class="icsrvalue"><%=conclusionList.get(i) %></span>  with <div class="toltip"><%=scoreVal %><span class="toltiptext"><span class="toltip-body"><%=df.format(prediction) %></span></span></div> confidence.</div>
											</div>

											<div id="rsummaryMachine<%=i %>" class="explanation-box rsummaryMachine<%=i %>" style="display: none;">
											<div class="c-image"> <img src="images/image002.png"></div>
											<!-- <div class="smily"><i class="fa fa-smile-o fa-3x" aria-hidden="true"></i></div> -->
											<span>Yes, I agree with you!   <i class="fa fa-smile-o fa-2x smily" aria-hidden="true"></i></span>
											</div>

										</div>
									</div>
								</div>

								<div id="my-legend<%=i %>" style="visibility: hidden;">
			<div class='my-legend' >
<div class="legend-title">Legends</div>
<div class="legend-scale">
  <ul class="legend-labels">
    <li><span style="background:#55ba75;"></span>Sure Yes</li>
    <li><span style="background:#f46161;"></span>Sure No</li>
    <li><span style="background:#edc03b;"></span>Tentative</li>
  </ul>
</div>
</div>
</div>
							<canvas id="canvasID<%=i %>" width="975" height="230" style="border:0px solid #000000;display:none" ></canvas>
								<!-- Start Iteration2 updates  first -->

								 <%
										 if(icsrExclusionList!=null && icsrExclusionList.size()>0)
										 {
											 for(int k=0;k<icsrExclusionList.size();k++)
											 {
												 Criteria criteria=(Criteria)icsrExclusionList.get(k);
												if(criteria.getStatus()!=null && criteria.getStatus().equalsIgnoreCase("Yes"))
												{
										 %>

										<script>
										 	var object1={
													"type":'<%=criteria.getCriteriaId()%>',
													"value":'<%= criteria.getValue()%>',
													"status":'<%=criteria.getStatus()%>'
													};
												remArr.push(object1);
										</script>
										 <%
												}	 %>
										<script>
											var obj = {
												 	"type":'<%= criteria.getCriteriaId() %>',
												 	"name":'<%= criteriaMap.get(criteria.getCriteriaId()) %>',
												 	"status": '<%= criteria.getStatus()%>',
													"value":'<%=criteria.getValue() %>',
													"score":'<%=criteria.getConfidence() %>'
									               	};
											 	excArr.push(obj);
										</script>
										<%	 }
										}
										%>
								<script>
									function populateCriteria1()
									{
									document.getElementById("icsrId1<%=i%>").innerHTML="";
									document.getElementById("icsrId2<%=i%>").innerHTML="";
									document.getElementById("icsrId3<%=i%>").innerHTML="";
									document.getElementById("icsrId4<%=i%>").innerHTML="";

									for(var n=0;n<excArr.length;n++)
									{
									if((excArr[n].status)!=null && ((excArr[n].status).trim() == "Yes") || (excArr[n].status).trim() == "yes"){

									document.getElementById("icsrId1<%=i%>").innerHTML = document.getElementById("icsrId1<%=i%>").innerHTML +
									"<div class='toltip toltip1'>"+excArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+excArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+excArr[n].score+"</br><b>Value : </b>"+excArr[n].value+"</span></span></div>&nbsp;&nbsp;";

									document.getElementById("icsrId2<%=i%>").innerHTML = document.getElementById("icsrId2<%=i%>").innerHTML +
									"<div class='toltip toltip1'>"+excArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+excArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+excArr[n].score+"</br><b>Value : </b>"+excArr[n].value+"</span></span></div>&nbsp;&nbsp;";

									document.getElementById("icsrId3<%=i%>").innerHTML = document.getElementById("icsrId3<%=i%>").innerHTML +
									"<div class='toltip toltip1'>"+excArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+excArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+excArr[n].score+"</br><b>Value : </b>"+excArr[n].value+"</span></span></div>&nbsp;&nbsp;";
									document.getElementById("icsrId4<%=i%>").innerHTML = document.getElementById("icsrId4<%=i%>").innerHTML +
									"<div class='toltip toltip1'>"+excArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+excArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+excArr[n].score+"</br><b>Value : </b>"+excArr[n].value+"</span></span></div>&nbsp;&nbsp;";

									}}
									}
									 populateCriteria();
								</script>



										 <%
										 if(icsrInclusionList!=null && icsrInclusionList.size()>0)
										 {
											 for(int m=0;m<icsrInclusionList.size();m++)
											 {
												 Criteria criteria=(Criteria)icsrInclusionList.get(m);
												if(criteria.getStatus()!=null && criteria.getStatus().equalsIgnoreCase("Yes"))
												{
										 %>

										<script>
										 var object1={
													"type":'<%=criteria.getCriteriaId()%>',
													"value":'<%= criteria.getValue()%>',
													"status":'<%=criteria.getStatus()%>'
													};
											remIncArr.push(object1);
										</script>
										 	<% }	%>

											<script>
												var obj = {
													 	"type":'<%= criteria.getCriteriaId() %>',
													 	"name":'<%= inclusionCriteriaMap.get(criteria.getCriteriaId()) %>',
													 	"status": '<%= criteria.getStatus()%>',
														"value":'<%=criteria.getValue() %>',
														"score":'<%=criteria.getConfidence() %>'
										                };
											 incArr.push(obj);
											</script>
										<%	 }
										}
										%>

									<script>
										function populateIncCriteria1()
										{

										document.getElementById("icsrIncId1<%=i%>").innerHTML="";
										document.getElementById("icsrIncId2<%=i%>").innerHTML="";
										document.getElementById("icsrIncId3<%=i%>").innerHTML="";
										document.getElementById("icsrIncId4<%=i%>").innerHTML="";

										for(var n=0;n<incArr.length;n++)
											{
											if((incArr[n].status)!=null && ((incArr[n].status).trim() == "Yes") || (incArr[n].status).trim() == "yes"){
													document.getElementById("icsrIncId1<%=i%>").innerHTML = document.getElementById("icsrIncId1<%=i%>").innerHTML +
													"<div class='toltip toltip2'>"+incArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+incArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+incArr[n].score+"</br><b>Value : </b>"+incArr[n].value+"</span></span></div>&nbsp;&nbsp;";

													document.getElementById("icsrIncId2<%=i%>").innerHTML = document.getElementById("icsrIncId2<%=i%>").innerHTML +
													"<div class='toltip toltip2'>"+incArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+incArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+incArr[n].score+"</br><b>Value : </b>"+incArr[n].value+"</span></span></div>&nbsp;&nbsp;";

													document.getElementById("icsrIncId3<%=i%>").innerHTML = document.getElementById("icsrIncId3<%=i%>").innerHTML +
													"<div class='toltip toltip2'>"+incArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+incArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+incArr[n].score+"</br><b>Value : </b>"+incArr[n].value+"</span></span></div>&nbsp;&nbsp;";

													document.getElementById("icsrIncId4<%=i%>").innerHTML = document.getElementById("icsrIncId4<%=i%>").innerHTML +
													"<div class='toltip toltip2'>"+incArr[n].name+"<span class='toltiptext'><span class='toltip-title'>"+incArr[n].name+"</span><span class='toltip-body'> <strong>Score : </strong>"+incArr[n].score+"</br><b>Value : </b>"+incArr[n].value+"</span></span></div>&nbsp;&nbsp;";

											}}
										}

										populateIncCriteria1();
									</script>

							</div>
							<!-- End Iteration2 updates First -->

						</div>
                            </div>
<script>
var index = -1;
var endex = -1;
var anchorTag ;
var focusTag ;
var start_pos=-1;
var end_pos=-1;
var arr = [];
mouseXPosition = 0;

$("#respText<%=i%>").mousedown(function (e1) {
    mouseXPosition = e1.pageX;//register the mouse down position
});

$('#respText<%=i%>').on("mouseup", function (e2) {


       var selection = window.getSelection();
       document.getElementById("respText<%=i%>").className="";
       focusTag = selection.anchorNode.parentNode;
    	anchorTag = selection.focusNode.parentNode;
       if ((e2.pageX - mouseXPosition) >0) {
         focusTag = selection.anchorNode.parentNode;
         anchorTag = selection.focusNode.parentNode;
     }
       selText=window.getSelection().toString();

        /* Code for calculating index positions of selected word */
         var mainDiv = document.getElementById("respText<%=i%>");
         var sel = getSelectionCharOffsetsWithin(mainDiv);
         start_pos=sel.start;
         end_pos=sel.end;
         var x = e2.pageX - this.offsetLeft;
   		 var y = e2.pageY - this.offsetTop;

        if(selText.length>0 && window.getSelection()!=null && window.getSelection().toString()!='' && window.getSelection().toString()!=' ')
      {
      //	document.getElementById("editpost").style.display="block";
      	/* var tstStr="display:block; position:absolute; left:"+x+"px;top:"+y +"px;"; */
        	if(x<500 ){
        	      var tstStr="display:block; position:absolute; left:"+x+"px;top: calc("+y +"px - 200px);";
        	} else if (x >500){
        	var tstStr="display:block; position:absolute; left:calc("+x+"px - 300px) ;top:calc("+y +"px - 200px);";
        	}

		//console.log ('tstStr',tstStr);
      document.getElementById("editpost").style=tstStr;
      	document.getElementById("lb").innerHTML=window.getSelection().toString();
       }
});

function getSelectionCharOffsetsWithin(element) {
         var start = 0, end = 0;
         var sel, range, priorRange;

         if (typeof window.getSelection != "undefined") {
           range = window.getSelection().getRangeAt(0);
           priorRange = range.cloneRange();
           priorRange.selectNodeContents(element);
           priorRange.setEnd(range.startContainer, range.startOffset);
           start = priorRange.toString().length;
           end = start + range.toString().length - 1;
         } else if (typeof document.selection != "undefined" &&
           (sel = document.selection).type != "Control") {
           range = sel.createRange();
           priorRange = document.body.createTextRange();
           priorRange.moveToElementText(element);
           priorRange.setEndPoint("EndToStart", range);
           start = priorRange.text.length;
           end = start + range.text.length;
         }
         return {
           start: start,
           end: end
         }
       }

function highlightSelection(mtype) {


       var userSelection = window.getSelection();
       document.getElementById("respText<%=i%>").className="";

       //Attempting to highlight multiple selections (for multiple nodes only + Currently removes the formatting)
       for(var i = 0; i < userSelection.rangeCount; i++) {
              //Copy the selection onto a new element and highlight it
              var node = highlightRange(userSelection.getRangeAt(i),mtype);
              var str=node.innerHTML;
              str = str.replace(/<\/?span[^>]*>/g,"");
              node.innerHTML=str;
              var range = userSelection.getRangeAt(i);
              //Delete the current selection
              range.deleteContents();
              //Insert the copy
              range.insertNode(node);
       }

       var obj = {
                    "type":mtype,
                    "user_feedback":selText,
                    "start_pos":start_pos,
                	"end_pos":end_pos
                };
           arr.push(obj);
       	closePopUp();
       	window.getSelection().removeAllRanges();
}

//Function that highlights a selection and makes it clickable
function highlightRange(range,mtype) {
    //Create the new Node
    var newNode = document.createElement("span");
    // Make it highlight
   if(mtype=="AE")
    	{
    	 newNode.setAttribute(
    		       "style",
    		       "border-bottom: solid 3px #9c27b0;"
    	  );
    	}
    if(mtype=="Drug")
	{
	 newNode.setAttribute(
		       "style",
		       "background-color: #a3daff;"
	  );
	}
    if(mtype=="Patient")
	{
	 newNode.setAttribute(
		       "style",
		       "border-bottom: 3px solid #aaff99;"
	  );
	}
    if(mtype=="Causal")
	{
	 newNode.setAttribute(
		       "style",
		       "border-bottom: solid 3px #3781f1;"
	  );
	}
    if(mtype=="Dose")
	{
	 newNode.setAttribute(
		       "style",
		       "background-color: #33FFE3;"
	  );
	}
    if(mtype=="JnjDrug")
	{
	 newNode.setAttribute(
		       "style",
		       "border-bottom: 3px solid #ffc9c9;"
	  );
	}

   /*  // Make it highlight
    newNode.setAttribute(
       "style",
       "background-color: yellow;"
    ); */
    newNode.appendChild(range.cloneContents());
    return newNode;
}

function deletenode(node){
       var contents = document.createTextNode(node.innerText);
       node.parentNode.replaceChild( contents, node);
}

function removeCategory()
{
var userSelection = window.getSelection();
var updateCat= window.getSelection().baseNode.parentNode;
//alert("userSelection::"+userSelection);
//alert("updateCat::"+updateCat);
var str;
       //Attempting to highlight multiple selections (for multiple nodes only + Currently removes the formatting)
       for(var i = 0; i < userSelection.rangeCount; i++) {
              //Copy the selection onto a new element and highlight it
              var newNode = document.createElement("span");
           	  newNode.appendChild(userSelection.getRangeAt(i).cloneContents());
              var range = userSelection.getRangeAt(i);
              //Delete the current selection
              range.deleteContents();
              //Insert the copy
              range.insertNode(newNode);
              deletenode(newNode);
              str=newNode.innerHTML;
       }
       //alert("str::"+str);
       if(str.indexOf("<span")==-1)
       {
    	   updateCat.style.borderBottom ='white';
       }

       var obj = {
                    "type":"Remove",
                    "user_feedback":selText,
                    "start_pos":start_pos,
         			"end_pos":end_pos
         		};
    	arr.push(obj);
       closePopUp();
}

var mArr = [];
var wsArr = [];
function addExclusionCreteria()
{
	<% if(masterExclusionList!=null && masterExclusionList.size()>0)
	{
		for(int j=0; j<masterExclusionList.size(); j++)
			{%>
		var checkId = document.getElementById("mcheckId"+<%=j%>).checked;
		if(checkId== true)
		{
			var obj = {
				 	"type":'<%= masterExclusionList.get(j)%>',
				 	"operation":"Add",
					"user_feedback":selText,
					"start_pos":start_pos,
	                "end_pos":end_pos
	                };
				mArr.push(obj);
				document.getElementById("mcheckId"+<%=j%>).checked=false;
		}

		<%}}%>

		for(var m=0;m<mArr.length;m++)
		{
			for(var n=0;n<excArr.length;n++)
			{
			if(mArr[m].type==excArr[n].type)
				{
					var SearchIndex
					excArr[n].status="Yes";
					if(excArr[n].value!=null && excArr[n].value!="" && excArr[n].value!="-")
					{

						var stuffArray = excArr[n].value.split(",");
						SearchIndex = stuffArray.indexOf(mArr[m].user_feedback);
						if(SearchIndex==-1)
							excArr[n].value=excArr[n].value+","+mArr[m].user_feedback;

					}
						 else
							{
								excArr[n].value=mArr[m].user_feedback;

							}
				}

			}

		}

var userSelection = window.getSelection();
 document.getElementById("respText<%=i%>").className="";
//Attempting to highlight multiple selections (for multiple nodes only + Currently removes the formatting)
for(var i = 0; i < userSelection.rangeCount; i++) {
	//Copy the selection onto a new element and highlight it
	var node = highlightExclusionRange(userSelection.getRangeAt(i)/*.toString()*/);
	var str=node.innerHTML;
	str = str.replace(/<\/?span[^>]*>/g,"");
	node.innerHTML=str;
	var range = userSelection.getRangeAt(i);
	//Delete the current selection
	range.deleteContents();
	//Insert the copy
	range.insertNode(node);
}
	closePopUp();
	document.getElementById("icsrId1<%=i%>").innerHTML = "";
	document.getElementById("icsrId2<%=i%>").innerHTML = "";
	document.getElementById("icsrId3<%=i%>").innerHTML = "";
	document.getElementById("icsrId4<%=i%>").innerHTML = "";
	populateCriteria();
	window.getSelection().removeAllRanges();
}

//Function that highlights a selection and makes it clickable
function highlightExclusionRange(range) {
    //Create the new Node
    var newNode = document.createElement("span");

    // Make it highlight
    newNode.setAttribute(
       "style",
       "background-color: #ffc107;"
    );


    newNode.appendChild(range.cloneContents());
    return newNode;
}

function removeExclusionCreteria()
{
	var rArr=[];

	<% if(masterExclusionList!=null && masterExclusionList.size()>0)
	{
	for(int j=0; j<masterExclusionList.size(); j++)
		{%>
		var checkId = document.getElementById("mcheckId"+<%=j%>).checked;
		if(checkId== true)
		{
				for (var n = 0 ; n < mArr.length ; n++) {
				    if (mArr[n].start_pos == start_pos && mArr[n].end_pos == end_pos && mArr[n].type=='<%= masterExclusionList.get(j)%>') {

				    	var ob1={"type":'<%= masterExclusionList.get(j)%>'};
				    	rArr.push(ob1);
				      var removedObject = mArr.splice(n,1);
				      removedObject = null;

				      break;
				    }
				}
		}
		<%}}%>

		<%-- document.getElementById("mcheckId"+<%=j%>).checked=false; --%>
		 var myJSO = JSON.stringify(remArr);
		<% if(masterExclusionList!=null && masterExclusionList.size()>0)
		{
		for(int j=0; j<masterExclusionList.size(); j++)
			{

			%>
			var checkId = document.getElementById("mcheckId"+<%=j%>).checked;
			if(checkId== true)
			{
			for(var p=0;p<remArr.length;p++)
			{
				var typ='<%= masterExclusionList.get(j)%>';
				if(remArr[p].type==typ && (remArr[p].status)!=null )
				{

				if((remArr[p].value=="" || remArr[p].value==null) && (selText=="" || selText.length==1))
					{
					start_pos=0;
					end_pos=0;
					var obj = {
						 	"type":'<%= masterExclusionList.get(j)%>',
						 	"operation": "Remove",
							"user_feedback":selText,
							"start_pos":start_pos,
			                "end_pos":end_pos
			                };
						wsArr.push(obj);
						break;

					}else if(remArr[p].value!=null && remArr[p].value!="")
						{
						var valArray=remArr[p].value.split(",");
						var valueArray = [];
						for (var i = 0; i < valArray.length; i++) {
							valueArray.push(valArray[i].toLowerCase());
						}
						var	sIndex = valueArray.indexOf(selText.toLowerCase());
						if(sIndex!=-1)
							{
							var obj = {
								 	"type":'<%= masterExclusionList.get(j)%>',
								 	"operation": "Remove",
									"user_feedback":selText,
									"start_pos":start_pos,
					                "end_pos":end_pos
					                };
								wsArr.push(obj);
								break;
							}
						}
				}
			}
			document.getElementById("mcheckId"+<%=j%>).checked=false;
			}
		<%}	}%>


		for(var m=0;m<rArr.length;m++)
		{
		for(var n=0;n<excArr.length;n++)
		{
			if(rArr[m].type==excArr[n].type)
			{
				var SearchIndex
				//excArr[n].status="Yes";
				if(excArr[n].value!=null && excArr[n].value!="")
				{
					var stArray = excArr[n].value.split(",");

					var stuffArray = [];
					for (var i = 0; i < stArray.length; i++) {
						stuffArray.push(stArray[i].toLowerCase());
					}
					SearchIndex = stuffArray.indexOf(selText.toLowerCase());
				if(stuffArray.length==1 && SearchIndex==0)
					{
					excArr[n].value="";
					}
				else if(stuffArray.length>1 && SearchIndex==0)
					{

					excArr[n].value=(excArr[n].value).substring(selText.length+1);

					}else if(SearchIndex!=-1 && stuffArray.length>1 && SearchIndex>0)
					{
						excArr[n].value=(excArr[n].value).substring(0,(excArr[n].value).toLowerCase().indexOf(selText.toLowerCase())-1)+(excArr[n].value).substring((excArr[n].value).toLowerCase().indexOf(selText.toLowerCase())+(selText).length);
					}
				}
				if(excArr[n].value==null || excArr[n].value=="" )
					{
					excArr[n].status="No";
					}
			}
	}

	}
	closePopUp();
	window.getSelection().removeAllRanges();
	document.getElementById("icsrId1<%=i%>").innerHTML = "";
	document.getElementById("icsrId2<%=i%>").innerHTML = "";
	document.getElementById("icsrId3<%=i%>").innerHTML = "";
	document.getElementById("icsrId4<%=i%>").innerHTML = "";
	populateCriteria();
}


var mIncArr = [];
var wsIncArr = [];
function addInclusionCreteria()
{

	<% if(masterInclusionList!=null && masterInclusionList.size()>0)
	{
	for(int j=0; j<masterInclusionList.size(); j++)
		{%>
		var checkId = document.getElementById("mcheckIncId"+<%=j%>).checked;
		if(checkId== true)
		{
			var obj = {
				 	"type":'<%= masterInclusionList.get(j)%>',
				 	"operation":"Add",
					"user_feedback":selText,
					"start_pos":start_pos,
	                "end_pos":end_pos
	                };
				mIncArr.push(obj);
				document.getElementById("mcheckIncId"+<%=j%>).checked=false;
		}

		<%}}%>
		for(var m=0;m<mIncArr.length;m++)
		{
			for(var n=0;n<incArr.length;n++)
			{
			if(mIncArr[m].type==incArr[n].type)
				{
					var SearchIndex
					incArr[n].status="Yes";
					if(incArr[n].value!=null && incArr[n].value!="" && incArr[n].value!="-")
					{

						var stuffArray = incArr[n].value.split(",");
						SearchIndex = stuffArray.indexOf(mIncArr[m].user_feedback);
						if(SearchIndex==-1)
							incArr[n].value=incArr[n].value+","+mIncArr[m].user_feedback;

					}
						 else
							{
								incArr[n].value=mIncArr[m].user_feedback;

							}
				}

			}

		}

var userSelection = window.getSelection();
 document.getElementById("respText<%=i%>").className="";
//Attempting to highlight multiple selections (for multiple nodes only + Currently removes the formatting)
for(var i = 0; i < userSelection.rangeCount; i++) {
	//Copy the selection onto a new element and highlight it
	var node = highlightInclusionRange(userSelection.getRangeAt(i)/*.toString()*/);
	var str=node.innerHTML;
	str = str.replace(/<\/?span[^>]*>/g,"");
	node.innerHTML=str;
	var range = userSelection.getRangeAt(i);
	//Delete the current selection
	range.deleteContents();
	//Insert the copy
	range.insertNode(node);
}
	closePopUp();
	document.getElementById("icsrIncId1<%=i%>").innerHTML="";
	document.getElementById("icsrIncId2<%=i%>").innerHTML="";
	document.getElementById("icsrIncId3<%=i%>").innerHTML="";
	document.getElementById("icsrIncId4<%=i%>").innerHTML="";
	populateIncCriteria();
	window.getSelection().removeAllRanges();
}

//Function that highlights a selection and makes it clickable
function highlightInclusionRange(range) {
    //Create the new Node
    var newNode = document.createElement("span");

    // Make it highlight
    newNode.setAttribute(
       "style",
       "background-color: #5cb85c;"
    );


    newNode.appendChild(range.cloneContents());
    return newNode;
}

function removeInclusionCreteria()
{
	var rArr=[];

	<% if(masterInclusionList!=null && masterInclusionList.size()>0)
	{
	for(int j=0; j<masterInclusionList.size(); j++)
		{%>
		var checkId = document.getElementById("mcheckIncId"+<%=j%>).checked;
		if(checkId== true)
		{

				for (var n = 0 ; n < mIncArr.length ; n++) {
				    if (mIncArr[n].start_pos == start_pos && mIncArr[n].end_pos == end_pos && mIncArr[n].type=='<%= masterInclusionList.get(j)%>') {

				    	var ob1={"type":'<%= masterInclusionList.get(j)%>'};
				    	rArr.push(ob1);
				      var removedObject = mIncArr.splice(n,1);
				      removedObject = null;

				      break;
				    }
				}
		}
		<%}}%>
				<% if(masterInclusionList!=null && masterInclusionList.size()>0)
				{
				for(int j=0; j<masterInclusionList.size(); j++)
					{%>
					var checkId = document.getElementById("mcheckIncId"+<%=j%>).checked;
					if(checkId== true)
					{
				for(var m=0;m<incArr.length;m++)
					{
					if(incArr[m].type=='<%= masterInclusionList.get(j)%>')
						{
						var SearchIndex
						if(incArr[m].value!=null && incArr[m].value!="")
						{
							var stArray = incArr[m].value.split(",");
							var stuffArray = [];
							for (var i = 0; i < stArray.length; i++) {
								stuffArray.push(stArray[i].toLowerCase());
							}
							SearchIndex = stuffArray.indexOf(selText.toLowerCase());
						if(stuffArray.length==1 && SearchIndex==0)
							{
							incArr[m].value="";
							}
						else if(stuffArray.length>1 && SearchIndex==0)
							{

							incArr[m].value=(incArr[m].value).substring(selText.length+1);

							}else if(SearchIndex!=-1 && stuffArray.length>1 && SearchIndex>0)
							{
								incArr[m].value=(incArr[m].value).substring(0,(incArr[m].value).toLowerCase().indexOf(selText.toLowerCase())-1)+(incArr[m].value).substring((incArr[m].value).toLowerCase().indexOf(selText.toLowerCase())+(selText).length);
							}
						}
						if(incArr[m].value==null || incArr[m].value=="" )
							{
							incArr[m].status="No";
							}

						}

					}
					}
				<%}}%>

		 var myJSO = JSON.stringify(remIncArr);
		<% if(masterInclusionList!=null && masterInclusionList.size()>0)
		{
		for(int j=0; j<masterInclusionList.size(); j++)
			{
			%>
			var checkId = document.getElementById("mcheckIncId"+<%=j%>).checked;
			if(checkId== true)
			{
			for(var p=0;p<remIncArr.length;p++)
			{
				var typ='<%= masterInclusionList.get(j)%>';
				if(remIncArr[p].type==typ && (remIncArr[p].status)!=null )
				{
				if((remIncArr[p].value=="" || remIncArr[p].value==null) && (selText=="" || selText.length==1))
					{
					start_pos=0;
					end_pos=0;
					var obj = {
						 	"type":'<%= masterInclusionList.get(j)%>',
						 	"operation": "Remove",
							"user_feedback":selText,
							"start_pos":start_pos,
			                "end_pos":end_pos
			                };
						wsIncArr.push(obj);
						break;

					}else if(remIncArr[p].value!=null && remIncArr[p].value!="")
						{
						var valArray = remIncArr[p].value.split(",");
						var valueArray = [];
						for (var i = 0; i < valArray.length; i++) {
							valueArray.push(v[i].toLowerCase());
						}
						var	sIndex = valueArray.indexOf(selText.toLowerCase());
						if(sIndex!=-1)
							{
							var obj = {
								 	"type":'<%= masterInclusionList.get(j)%>',
								 	"operation": "Remove",
									"user_feedback":selText,
									"start_pos":start_pos,
					                "end_pos":end_pos
					                };
								wsIncArr.push(obj);
								break;

							}

						}
				}
			}
			document.getElementById("mcheckIncId"+<%=j%>).checked=false;
			}

		<%}	}%>

		for(var m=0;m<rArr.length;m++)
		{
		for(var n=0;n<incArr.length;n++)
		{
			if(rArr[m].type==incArr[n].type)
			{
				var SearchIndex
				//excArr[n].status="Yes";
				if(incArr[n].value!=null && incArr[n].value!="")
				{
					var stArray = incArr[n].value.split(",");
					var stuffArray = [];
					for (var i = 0; i < stArray.length; i++) {
						stuffArray.push(stArray[i].toLowerCase());
					}
					SearchIndex = stuffArray.indexOf(selText.toLowerCase());
				if(stuffArray.length==1 && SearchIndex==0)
					{
					incArr[n].value="";
					}
				else if(stuffArray.length>1 && SearchIndex==0)
					{

					incArr[n].value=(incArr[n].value).substring(selText.length+1);

					}else if(SearchIndex!=-1 && stuffArray.length>1 && SearchIndex>0)
					{
						incArr[n].value=(incArr[n].value).substring(0,(incArr[n].value).toLowerCase().indexOf(selText.toLowerCase())-1)+(incArr[n].value).substring((incArr[n].value).toLowerCase().indexOf(selText.toLowerCase())+(selText).length);
					}
				}
				if(incArr[n].value==null || incArr[n].value=="" )
					{
					incArr[n].status="No";
					}
			}
	}

	}

	closePopUp();
	window.getSelection().removeAllRanges();
	document.getElementById("icsrIncId1<%=i%>").innerHTML="";
	document.getElementById("icsrIncId2<%=i%>").innerHTML="";
	document.getElementById("icsrIncId3<%=i%>").innerHTML="";
	document.getElementById("icsrIncId4<%=i%>").innerHTML="";
	populateIncCriteria();
}

function closePopUp()
{
       document.getElementById("editpost").style.display="none";
}
function winclose()
{
	closePopUp();

}
</script>

                            <%} %>
                        </div>
							<div class="row">
								<div class="col-sm-12">
								<!-- <button type="button" id="fdBtn" class="btn  btn-back" onclick="viewSummaryList();">Back</button> -->
								<a href="#" id="fdBtn" class="back-button" onclick="viewSummaryList();"><i class="fa fa-chevron-circle-left" aria-hidden="true"></i> Back</a>
									<!-- <span class="back-btn"><img id="fdBtn" src="images/back.png" width="5%" onclick="viewSummaryList();" /></span> -->

								</div>

							</div>
						</div>

					</div>
	</div>

	<!-- <button type="button" onclick="topFunction()" id="myBtn" title="Go to top" style="display: block;">Top</button> -->

	<script>

	// When the user clicks on the button, scroll to the top of the document
	function topFunction() {
	document.body.scrollTop = 0;
	document.documentElement.scrollTop = 0;
	}
	</script>

			</div>
		</div>
		<%}else{ %>
			No JnJ Drug Found....
			<br><br>
			<div class="col-sm-12">
				<button type="button" id="fdBtn" class="btn  btn-back" onclick="viewSummaryList();">Back</button>
			</div>
			<%} %>
	</div>



	<div id="editpost" style="display:none">
								<span onclick="winclose();" class="pull-right my-close-btn">
									<i class="fa fa-window-close" aria-hidden="true"></i>
								</span>
								<ul class="nav nav-tabs nav-fill">
									<li class="active">
										<a href="#1" data-toggle="tab" class="nav-item nav-link">Entity Selection</a>
									</li>
									<li>
										<a href="#2" data-toggle="tab" class="nav-item nav-link">ICSR Exclusion</a>
									</li>
									<li>
										<a href="#3" data-toggle="tab" class="nav-item nav-link">ICSR Inclusion</a>
									</li>
								</ul>
								<div id="lb" class="lb-posts"></div>
								<div class="tab-content ">
									<div class="tab-pane active" id="1">
										<button type="button" id="aeButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('AE');">AE</button>
										<!-- <button type="button" id="drugButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('Drug');">Drug</button> -->
										<button type="button" id="patientButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('Patient');">Patient</button>
										<button type="button" id="causalButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('Causal');">Causal attribution</button>
										<!-- <button type="button" id="doseButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('Dose');">Dose</button> -->
										<!-- <button type="button" id="reporterButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('Reporter');">Reporter</button> -->
										<button type="button" id="jnjdrugButt" name="Add" class="btn btn-sm btn-gray" onclick="highlightSelection('JnjDrug');">JNJDrug</button>
										<button type="button" id="remButt" name="Remove" class="btn btn-sm btn-gray" onclick=" removeCategory();">Remove</button>
									</div>
									<!--  Start Tabs content for iteration2 -->
									<div class="tab-pane show-exclusion" id="2">
										<%
										if(masterExclusionList!=null && masterExclusionList.size()>0)
										{
										for(int j=0;j<masterExclusionList.size();j++)
										{
										%>
										<label class="exclusion-container"><%= criteriaMap.get(masterExclusionList.get(j))%>
										  <input type="checkbox" name="<%=masterExclusionList.get(j)%>" id="mcheckId<%=j%>" >
										  <span class="checkmark"></span>
										</label>
										<%} }%>
										<div class="btn-action text-right">
											<button type="button" class="btn btn-sm btn-gray" onclick="addExclusionCreteria();">Add</button>
											<button type="button" class="btn btn-sm btn-gray" onclick="removeExclusionCreteria();">Remove</button>
										</div>
									</div>

									<!-- End Tabs content for iteration2 -->
									<!--  Start Tabs content for iteration3 -->
									<div class="tab-pane show-exclusion" id="3">
										<%
										if(masterInclusionList!=null && masterInclusionList.size()>0)
										{
										for(int j=0;j<masterInclusionList.size();j++)
										{
										%>
										<label class="exclusion-container"><%= inclusionCriteriaMap.get(masterInclusionList.get(j))%>
										  <input type="checkbox" name="<%=masterInclusionList.get(j)%>" id="mcheckIncId<%=j%>" >
										  <span class="checkmark"></span>
										</label>
										<%} }%>
										<div class="btn-action text-right">
											<button type="button" class="btn btn-sm btn-gray" onclick="addInclusionCreteria();">Add</button>
											<button type="button" class="btn btn-sm btn-gray" onclick="removeInclusionCreteria();">Remove</button>
										</div>
									</div>
									<!-- End Tabs content for iteration3 -->
								</div>
							</div>



 <!-- All Jquery -->
    <script src="js/lib/bootstrap/js/popper.min.js"></script>
    <script src="js/lib/bootstrap/js/bootstrap.min.js"></script>
    <!-- slimscrollbar scrollbar JavaScript -->
    <script src="js/jquery.slimscroll.js"></script>

    <!--stickey kit -->
    <script src="js/lib/sticky-kit-master/dist/sticky-kit.min.js"></script>
    <script src="js/lib/owl-carousel/owl.carousel.min.js"></script>
    <script src="js/lib/owl-carousel/owl.carousel-init.js"></script>
    <script src="js/scripts.js"></script>

	<script>
		var selText="";
		var icsrExcStr 			= <%=icsrExclusion%>;
		var icsrIncStr			= <%=icsrInclusion %>;
		var myMap = new Map();
		myMap.set("specialSituation", "Special Situation");
	   	myMap.set("Attribution", "Attribution");
	   	myMap.set("concomitant_drug", "Concomitant Med");
	   	myMap.set("metaanalysis", "Meta-analysis");
	   	myMap.set("no_patient", "No Patient");
	   	myMap.set("Pregnancy", "Pregnancy");
	   	myMap.set("Breastfeeding", "Breastfeeding");
	   	myMap.set("Animal", "Animal");
	   	myMap.set("no_ade", "No ADE");
	   	myMap.set("abuse_or_misuse", "Abuse/Misuse");
	 	myMap.set("lack_of_effect","Lack of Effect");
	 	myMap.set("transmission_issues","Transmission Issues");
	 	myMap.set("accidental_exposure", "Accidental Exposure");
	 	myMap.set("Review_Article","Review Article");
	 	myMap.set("In_vitro","In Vitro");

	 	//myMap.set("no_causality","No causality");
		//myMap.set("medication_error", "Medication Error");
		 //myMap.set("Off_Label_Use", "Off Label Use");
		 // myMap.set("company_trial", "Company Sponsered Trial");
		//myMap.set("overdose", "Overdose");
		 //console.log(myMap.get(key1));
		var	JnjDrug 			= "Jnj Drug",
			Mah 				= "Mah",
		 	incidental 			= "Incidental" ,
			specialSituation 	= "Special Situation",
			JnjIcsrNo	 		= "ICSR No",
			ssIcsrYes 			= "ICSR Yes",
			ssIcsrNo 			= "ICSR No ",
			mahIcsrNo 			= "ICSR NO",
			incidentalIcsrNo 	= " ICSR No",
			Attribution 		= "Attribution",
			attrIcsrNo 			= " ICSR No ",
			attrIcsrYes 		= " ICSR Yes",
			Animal				= "Animal",
			concomitant_drug	= "Concomitant Med",
			no_ade				= "No ADE",
			metaanalysis		= "Meta-analysis",
			no_patient			= "No Patient",
			Review_Article		= "Review Article",
			In_vitro			= "In Vitro",
			Pregnancy			= "Pregnancy",
			Breastfeeding		= "Breastfeeding",
			abuse_or_misuse		= "Abuse/Misuse",
			starting			= "Start",
			accidental_exposure	= "Accidental Exposure",
			transmission_issues	= "Transmission Issues",
			lack_of_effect		= "Lack of Effect",
			no_causality		= "No Causality";


		function viewSummaryList()
		{
			window.open("drugCodeSummary.jsp","_self");
		}

		// Get all the html in your text container

		$('ul.nav-tabs li a').click(function (e) {
		  $('ul.nav-tabs li.active').removeClass('active')
		  $(this).parent('li').addClass('active')
		})
	</script>


	<script>

	function updateRevIndex(index)
	{
		var exBox="toltipInc"+parseInt(index-1);

		document.getElementById("revInd").innerHTML=index;

		for(var i=0; i<reviewedTab.length;i++)
		{
			document.getElementById("nav-"+reviewedTab[i]+"-tab").className='nav-item nav-link reviewd-tab';
				if(revICSRList[i]=="icsrYes")
					{
					document.getElementById("icsrYes"+reviewedTab[i]).checked=true;
					displayBox('ICSR Yes',reviewedTab[i]);
					}
				if(revICSRList[i]=="icsrNo")
					{
					document.getElementById("icsrNo"+reviewedTab[i]).checked=true;
					displayBox('ICSR No',reviewedTab[i]);
					}
				if(fullTextReviewList[i]=="Yes")
				{
				document.getElementById("fulltext"+reviewedTab[i]).checked=true;
				}
				if(fullTextReviewList[i]=="No")
				{
				document.getElementById("fulltext"+reviewedTab[i]).checked=false;
				}
				document.getElementById("feedBack"+reviewedTab[i]).value=revCommentsList[i];
				document.getElementById("respText"+reviewedTab[i]).style.pointerEvents = "none";


		}


		/* var tabIndex=parseInt(index-1);
		alert("indexof::"+reviewedTab.indexOf(0));
		if(reviewedTab.indexOf(tabIndex)!=-1)
		{

		document.getElementById(exBox).style.display='block';
		}else
			{
			document.getElementById(exBox).style.display='none';
			} */
		if(reviewedTab.length=='<%=jnjDrugListNew.size()-1%>' || 1==<%=jnjDrugListNew.size()%>)
			{
			var buttId="reviewId"+parseInt(index-1);
			document.getElementById(buttId).innerHTML= 'Submit Assessment';
			}
		<% if(masterExclusionList!=null && masterExclusionList.size()>0)
		{
		for(int j=0; j<masterExclusionList.size(); j++)
			{%>
			document.getElementById("mcheckId"+<%=j%>).checked=false;
			<%}}%>

		<% if(masterInclusionList!=null && masterInclusionList.size()>0)
		{
		for(int j=0; j<masterInclusionList.size(); j++)
			{%>
			document.getElementById("mcheckIncId"+<%=j%>).checked=false;
			<%}}%>
	}





function displayBox(icsrVal, num)
	{
	/* if(document.getElementById("icsrYes"+num).checked==true || document.getElementById("icsrNo"+num).checked==true)
	{
	document.getElementById("canvasID"+num).style.display="block";
	} */
	<% if(role!=null && role.equalsIgnoreCase("supervisor")) {%>
		var conclusions=conclusionList[num];

		<%-- var conclusions='<%=conclusion%>'; --%>
		var listsize='<%=jnjDrugListNew.size()%>';
		var divBox="icsrResults"+num;
		var rs1="#rsummary1"+num;
		var rs2="#rsummary2"+num;
		var rs3="#rsummary3"+num;
		var rs4="#rsummary4"+num;
		var rsNo1="#rsummaryNo1"+num;

		var rsM="#rsummaryMachine"+num;
		if(conclusions==icsrVal)
		{
		showBox="no";
		//document.getElementById(divBox).style.display='none';
		//fadeOut(document.getElementById(divBox));
		//$("#"+rs1, "#"+rs2, "#"+rs3, "#"+rs4).fadeOut(500);
		$(rs1).fadeOut(500);
		$(rs2).fadeOut(500);
		$(rs3).fadeOut(500);
		$(rs4).fadeOut(500);
		$(rsNo1).fadeOut(500);
		$(rsM).fadeIn(500);
		document.getElementById(divBox).style.display='block';
		// $(divBox).fadeOut(1000);
		}else
			{
			showBox="yes";

			populateCriteria();
			document.getElementById(divBox).style.display='block';
			var myarray= new Array(rs1, rs2, rs3,rs4);
			var ChosenDiv = myarray[Math.floor(Math.random() * myarray.length)];
			console.log(ChosenDiv);
			if(conclusions=='ICSR Yes')
			{
				var elements = document.getElementsByClassName('icsrvalue');
				for (var i = 0; i < elements.length; i++) {
				    elements[i].style.color = 'green';
				}
				 $(ChosenDiv).fadeIn(500);

			}else{
				var elements = document.getElementsByClassName('icsrvalue');
				for (var i = 0; i < elements.length; i++) {
				    elements[i].style.color = 'red';
				    $(rsNo1).fadeIn(500);
				}
			}
			 $(rsM).fadeOut(500);

			 setTimeout(function(){$(".toltip .toltiptext").css('visibility','visible'); }, 2000);
			 setTimeout(function(){ $(".toltip .toltiptext").css('visibility','hidden'); }, 4000);

			// $(divBox).fadeIn(1000);
			 document.body.scrollTop = 500;
			 document.documentElement.scrollTop = 500;
			}
<%	}%>
			}
	function displayChart(num, conclusionForIcsr)
	{
		<% if(role!=null && role.equalsIgnoreCase("supervisor")) {%>
		$('html,body').animate({scrollTop: document.body.scrollHeight},"fast");
		document.getElementById("canvasID"+num).style.display="block";
		var graph = new flowjs.DiGraph();
		graph.addPaths([
			[starting,JnjDrug],
			[starting,JnjIcsrNo],
			[JnjDrug,Mah,incidental],
			[incidental,specialSituation],
		    [specialSituation,ssIcsrYes],
		    [Attribution,attrIcsrYes],
		    //[ssIcsrYes,overdose],
		    //[ssIcsrYes,medication_error],
		    //[ssIcsrYes,Off_Label_Use],
		    [ssIcsrYes,Breastfeeding],
		    [ssIcsrYes,accidental_exposure],
		    [ssIcsrYes,transmission_issues],
		    [ssIcsrYes,abuse_or_misuse],
		    [ssIcsrYes,lack_of_effect],
		    [ssIcsrYes,Pregnancy],
		    [specialSituation,Attribution],
		    [JnjIcsrNo, Animal],
		    [JnjIcsrNo,metaanalysis],
		    [JnjIcsrNo,no_patient],
		    [JnjIcsrNo,concomitant_drug],
		    [JnjIcsrNo,no_causality],
		    [JnjIcsrNo,In_vitro],
		    [JnjIcsrNo,no_ade],
		    [JnjIcsrNo,Review_Article],
		    //[JnjIcsrNo,company_trial],
		]);
		//results1
		var flow = new flowjs.DiFlowChart("canvasID"+num, graph);
		flow.draw();
		simuLoad(flow,graph,conclusionForIcsr);

		 var domElement = new createjs.DOMElement(document.getElementById("my-legend"+num)),
		canvas	= document.getElementById("canvasID"+num);
	domElement.x = 10;
	domElement.y = 10;
	flow.stage.addChild(domElement);

	 (document.getElementById("canvasID"+num)).style.animation = "2s ease-out 0s 1 slideInFromLeft " ;
	 <%}%>
			}

	function simuLoad(flowChart, graph,conclusionForIcsr)
	{
        var walker = new flowjs.GraphWalker(graph);

        walker.forEach(function(node){
          var start = 0;
          var dur = 0;
          var green	= "#55ba75",
           	red 	= "#f46161",
           	yellow	= "#edc03b";

          	//simulateLoading(starting, start);
      		simulateDoneLoading(starting, start + dur, green);

    	 if(conclusionForIcsr == "ICSR No")
        	  {
            	simulateDoneLoading(JnjIcsrNo, start + dur, red);
        	  }
          else if(conclusionForIcsr == "ICSR Yes")
        	  {
        	    simulateDoneLoading(attrIcsrYes, start + dur, green);
          		simulateDoneLoading(Attribution, start + dur, green);
         	  }
    	 console.log(icsrExcStr);
    	 for(var l=0; l<icsrExcStr.length; l++)
         {
         	var icsrExcType;
         	var icsrExcStatus;
         	var icsrExcObj = icsrExcStr[l];


         	if(icsrExcObj.type == "non_jnj_product" && icsrExcObj.exclusion_status =="No")
         	{
         		simulateDoneLoading(JnjDrug, start + dur, green);
         	}
         	if(icsrExcObj.type == "NOT_MAH" && icsrExcObj.exclusion_status =="No")
         	{
         		simulateDoneLoading(JnjDrug, start + dur, green);
         	}
         	else if(icsrExcObj.type =="NOT_MAH" && icsrExcObj.exclusion_status == "Yes")
     		{
         		simulateDoneLoading(Mah, start + dur, yellow);
     		}

         	if(icsrExcObj.type =="incidental" && icsrExcObj.exclusion_status == "No")
     		{
     			simulateDoneLoading(incidental, start + dur, green);
     		}else if (icsrExcObj.type =="incidental" && icsrExcObj.exclusion_status == "Yes")
     			{
            		simulateDoneLoading(incidental, start + dur, yellow);
     			}
         	if (icsrExcObj.type =="negative causality" && icsrExcObj.exclusion_status == "Yes")
 			{
        		simulateDoneLoading(no_causality, start + dur, yellow);
 			}

          if(myMap.has(icsrExcObj.type)&& icsrExcObj.exclusion_status =="Yes")
     		{
     			simulateDoneLoading(myMap.get(icsrExcObj.type), start + dur, yellow);
     		}
         }

         for(var m=0; m<icsrIncStr.length; m++)
         {
         	var icsrIncType ;
         	var icsrIncStatus ;
         	var icsrIncObj = icsrIncStr[m];

         	if(icsrIncObj.type!=="undefined" && icsrIncObj.type!==null)
         	{
         		var icsrIncType =  icsrIncObj.type;
         	}
         	if(icsrIncObj.inclusion_status!=="undefined" && icsrIncObj.inclusion_status!==null)
         	{
         		var icsrIncStatus =  icsrIncObj.inclusion_status;
         	}
         	if(myMap.has(icsrIncType)&& icsrIncStatus =="Yes")
     		{
     			simulateDoneLoading(specialSituation, start + dur, yellow);
         		simulateDoneLoading(ssIcsrYes, start + dur, yellow);
         		simulateDoneLoading(myMap.get(icsrIncType), start + dur, yellow);
     		}

       }

       }, this);


        /* function simulateLoading(itemId, timeout){
            setTimeout(function(){
                flowChart.updateItem(itemId, function(item){
                    item.flowItem.toggleFlashing();
                });
            }, timeout);

        } */

        function simulateDoneLoading(itemId, timeout, color){
            setTimeout(function(){
                flowChart.updateItem(itemId, function(item){
                    item.flowItem.toggleFlashing();
                    item.flowItem.color = color;
                    if (item.connectors === undefined){return;}
                    item.connectors.forEach(function(conn){
                       conn.color = color;
                    });
                });
            }, timeout);
        }
    }




	$(document).ready(function(){


		$(".toltip").mouseover(function(){
		  $(".toltiptext").css("visibility", "visible");
		//console.log('In');
		});
		$(".toltip").mouseout(function(){
		  $(".toltiptext").css("visibility", "hidden");
		//console.log('out');
		});

		$('.legend-checkbox input[type="checkbox"]').click(function(){
	        if(!$(this).is(':checked')){
	           $(this).parent('.legend-checkbox').removeClass('highlight-label');
	    }else{
	           $(this).parent('.legend-checkbox').addClass('highlight-label');
	    }
	});

	});
</script>

</body>
</html>