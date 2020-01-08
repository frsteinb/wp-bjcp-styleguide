<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:bjcp="http://heimbrauconvention.de/bjcp-styleguide/2015"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:func="http://exslt.org/functions"
  xmlns:math="http://exslt.org/math"
  xmlns:brew="http://frankensteiner.familie-steinberg.org/brew"
  extension-element-prefixes="exsl str func math">



  <xsl:template name="subst">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>

    <xsl:choose>
      <xsl:when test="string-length($replace) = 0">
        <xsl:value-of select="$text"/>
      </xsl:when>
      <xsl:when test="contains($text, $replace)">

        <xsl:variable name="before" select="substring-before($text, $replace)"/>
        <xsl:variable name="after" select="substring-after($text, $replace)"/>

        <xsl:value-of select="$before"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="subst">
          <xsl:with-param name="text" select="$after"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when> 
      <xsl:otherwise>
        <xsl:value-of select="$text"/>  
      </xsl:otherwise>
    </xsl:choose>            
  </xsl:template>



  <func:function name="brew:sgToPlato">
    <xsl:param name="sg"/>
    <xsl:variable name="r">
      <xsl:value-of select="(-1 * 616.868) + (1111.14 * $sg) - (630.272 * math:power($sg,2)) + (135.997 * math:power($sg,3))"/>
    </xsl:variable>
    <func:result select="$r"/>
  </func:function>



  <func:function name="brew:srmToEbc">
    <xsl:param name="srm"/>
    <xsl:variable name="r">
      <xsl:value-of select="$srm div 0.508"/>
    </xsl:variable>
    <func:result select="$r"/>
  </func:function>



  <func:function name="brew:bitterWort">
    <xsl:param name="ibu"/>
    <xsl:param name="sg"/>
    <xsl:variable name="plato">
      <xsl:value-of select="brew:sgToPlato($sg)"/>
    </xsl:variable>
    <xsl:variable name="q">
      <xsl:value-of select="$ibu div $plato"/>
    </xsl:variable>
    <xsl:variable name="r">
      <xsl:choose>
	<xsl:when test="1.5 >= $q">sehr malzig</xsl:when>
	<xsl:when test="2.0 >= $q">malzig</xsl:when>
	<xsl:when test="2.2 >= $q">ausgewogen</xsl:when>
	<xsl:when test="3.0 >= $q">herb</xsl:when>
	<xsl:when test="6.0 >= $q">sehr herb</xsl:when>
	<xsl:otherwise>Hopfenbombe</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result select="$r"/>
  </func:function>



  <xsl:template match="/bjcp:styleguide">
    <exsl:document href="-" method="text" encoding="UTF-8"
                   omit-xml-declaration="yes">
      <xsl:text>DELETE FROM `wp_posts` WHERE post_content LIKE '<![CDATA[<!-- auto-generated bjcp glossary post-->]]>%';
</xsl:text>
      <xsl:apply-templates select="( //bjcp:category | //bjcp:subcategory )"/>
    </exsl:document>
  </xsl:template>

  <xsl:template match="bjcp:subcategory/bjcp:subcategory" mode="classification">
    <xsl:apply-templates select=".." mode="classification"/>
    <xsl:text>- - - Alternative: </xsl:text>
    <xsl:value-of select="bjcp:name"/>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="bjcp:category/bjcp:subcategory" mode="classification">
    <xsl:apply-templates select=".." mode="classification"/>
    <xsl:text>- - Unterkategorie </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="bjcp:name"/>
    <xsl:text>)</xsl:text>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="bjcp:category" mode="classification">
    <xsl:text>- Kategorie </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="bjcp:name"/>
    <xsl:text>)</xsl:text>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="section">
    <xsl:text><![CDATA[<dt>]]></xsl:text>
    <xsl:choose>
      <xsl:when test="local-name(.) = 'description'">Beschreibung</xsl:when>
      <xsl:when test="local-name(.) = 'overall-impression'">Gesamteindruck</xsl:when>
      <xsl:when test="local-name(.) = 'aroma'">Geruch</xsl:when>
      <xsl:when test="local-name(.) = 'appearance'">Erscheinungsbild</xsl:when>
      <xsl:when test="local-name(.) = 'flavor'">Geschmack</xsl:when>
      <xsl:when test="local-name(.) = 'mouthfeel'">Mundgefühl</xsl:when>
      <xsl:when test="local-name(.) = 'comments'">Kommentare</xsl:when>
      <xsl:when test="local-name(.) = 'history'">Geschichte</xsl:when>
      <xsl:when test="local-name(.) = 'characteristic-ingredients'">Charakteristische Zutaten</xsl:when>
      <xsl:when test="local-name(.) = 'style-comparison'">Stilvergleich</xsl:when>
      <xsl:when test="local-name(.) = 'entry-instructions'">Einreichungsbestimmungen</xsl:when>
      <xsl:when test="local-name(.) = 'commercial-examples'">Kommerzielle Beispiele</xsl:when>
      <xsl:when test="local-name(.) = 'specs'">Eckdaten</xsl:when>
      <xsl:when test="local-name(.) = 'tags'">Tags</xsl:when>
      <xsl:when test="local-name(.) = 'strength-classifications'">Stärkeklassifikationen</xsl:when>
    </xsl:choose>
    <xsl:text><![CDATA[</dt>]]></xsl:text>
    <xsl:text><![CDATA[<dd>]]></xsl:text>
    <xsl:call-template name="subst">
      <xsl:with-param name="text" select="."/>
      <xsl:with-param name="replace">'</xsl:with-param>
      <xsl:with-param name="with">\'</xsl:with-param>
    </xsl:call-template>
    <xsl:text><![CDATA[</dd>]]></xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="children">
    <xsl:variable name="list" select="./*[name]"/>
    <xsl:for-each select="$list">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:text><![CDATA[<dt>]]></xsl:text>
          <xsl:value-of select="substring(concat(translate(substring(local-name(.),1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(local-name(.),2)),1,string-length(local-name(.))-1)"/>
          <xsl:text><![CDATA[ies</dt>]]></xsl:text>
          <xsl:text><![CDATA[<dd>]]></xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>, </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="./bjcp:name"/>
      <xsl:if test="position() = last()">
        <xsl:text><![CDATA[</dd>]]></xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="bjcp:specs">
    <xsl:text><![CDATA[<dt>]]>Eckdaten<![CDATA[</dt>]]></xsl:text>
    <xsl:text><![CDATA[<dd>]]></xsl:text>
    <xsl:text><![CDATA[<table>]]></xsl:text>
    <xsl:if test="bjcp:ibu/@min">
      <xsl:text><![CDATA[<tr><td>Bittere</td><td>]]></xsl:text>
      <xsl:value-of select="bjcp:ibu/@min"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="bjcp:ibu/@max"/>
      <xsl:text> IBU</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:if test="bjcp:og/@min">
	<xsl:text>( </xsl:text>
	<xsl:value-of select="brew:bitterWort(bjcp:ibu/@min, bjcp:og/@max)"/>
	<xsl:text> - </xsl:text>
	<xsl:value-of select="brew:bitterWort(bjcp:ibu/@max, bjcp:og/@min)"/>
	<xsl:text> )</xsl:text>
      </xsl:if>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="bjcp:srm/@min">
      <xsl:text><![CDATA[<tr><td>Farbe</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:srmToEbc(bjcp:srm/@min),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:srmToEbc(bjcp:srm/@max),'0.0')"/>
      <xsl:text> EBC</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:value-of select="bjcp:srm/@min"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="bjcp:srm/@max"/>
      <xsl:text> SRM</xsl:text>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="bjcp:og/@min">
      <xsl:text><![CDATA[<tr><td>Stammwürze</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(bjcp:og/@min),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(bjcp:og/@max),'0.0')"/>
      <xsl:text> °P</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text>OG </xsl:text>
      <xsl:value-of select="bjcp:og/@min"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="bjcp:og/@max"/>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="bjcp:fg/@min">
      <xsl:text><![CDATA[<tr><td>Restextrakt</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(bjcp:fg/@min),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(bjcp:fg/@max),'0.0')"/>
      <xsl:text> GG%</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text>FG </xsl:text>
      <xsl:value-of select="bjcp:fg/@min"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="bjcp:fg/@max"/>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="bjcp:abv/@min">
      <xsl:text><![CDATA[<tr><td>Alkohol</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(bjcp:abv/@min,'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(bjcp:abv/@max,'0.0')"/>
      <xsl:text> %vol</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:text><![CDATA[</table>]]></xsl:text>
    <xsl:text><![CDATA[</dd>]]></xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="asis">
    <xsl:text><![CDATA[<]]></xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:text><![CDATA[>]]></xsl:text>
    <xsl:apply-templates select="* | @* | text()" mode="asis"/>
    <xsl:text><![CDATA[</]]></xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:text><![CDATA[>]]></xsl:text>
  </xsl:template>

  <xsl:template match="@*" mode="asis">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="asis"/>
      <xsl:apply-templates mode="asis"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="asis">
    <xsl:call-template name="subst">
      <xsl:with-param name="text" select="."/>
      <xsl:with-param name="replace">'</xsl:with-param>
      <xsl:with-param name="with">\'</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="bjcp:category | bjcp:subcategory">
    <xsl:variable name="id">
      <xsl:choose>
	<xsl:when test="@type">
	  <xsl:value-of select="@type"/>
	</xsl:when>
	<xsl:when test="@id">
	  <xsl:value-of select="@id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="bjcp:name"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:choose>
	<xsl:when test="@type">
          <xsl:value-of select="translate(substring(@type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
          <xsl:value-of select="substring(@type,2)"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:value-of select="bjcp:name"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="postname">bjcp-<xsl:value-of select="translate($id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz-')"/></xsl:variable>
    <xsl:text>INSERT INTO `wp_posts` (post_author,post_date,post_date_gmt,post_content,post_title,post_excerpt,comment_status,ping_status,post_name,to_ping,pinged,post_modified,post_modified_gmt,post_content_filtered,post_type) VALUES (1,NOW(),NOW(),'<![CDATA[<!-- auto-generated bjcp glossary post-->]]></xsl:text>

    <xsl:text><![CDATA[</h2><dt>Klassifizierung</dt><dd>]]></xsl:text>
    <xsl:apply-templates select="." mode="classification"/>
    <xsl:text><![CDATA[</dd>]]></xsl:text>

    <xsl:apply-templates select="bjcp:description" mode="section"/>
    
    <xsl:apply-templates select="bjcp:overall-impression" mode="section"/>
    <xsl:apply-templates select="bjcp:aroma" mode="section"/>
    <xsl:apply-templates select="bjcp:appearance" mode="section"/>
    <xsl:apply-templates select="bjcp:flavor" mode="section"/>
    <xsl:apply-templates select="bjcp:mouthfeel" mode="section"/>
    <xsl:apply-templates select="bjcp:comments" mode="section"/>
    <xsl:apply-templates select="bjcp:history" mode="section"/>
    <xsl:apply-templates select="bjcp:characteristic-ingredients" mode="section"/>
    <xsl:apply-templates select="bjcp:style-comparison" mode="section"/>
    <xsl:apply-templates select="bjcp:entry-instructions" mode="section"/>

    <xsl:apply-templates select="bjcp:strength-classifications" mode="section"/>
    
    <xsl:apply-templates select="bjcp:commercial-examples" mode="section"/>
    <xsl:apply-templates select="bjcp:specs"/>
    <xsl:apply-templates select="bjcp:tags" mode="section"/>

    <!--
    <xsl:apply-templates select="." mode="specialties"/>
    -->
    
    <xsl:apply-templates select="." mode="children"/>

    <xsl:text></xsl:text><xsl:text><![CDATA[<p style="font-size: 70%;">Diese Informationen entstammen dem <a href="https://heimbrauconvention.de/index.php/bjcp-styleguide/">Übersetzungsprojekt</a> der <a href="http://dev.bjcp.org/beer-styles/introduction-to-the-2015-guidelines/">BJCP Style Guidelines</a>.</p>]]></xsl:text>

    <xsl:text>','</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>','','closed','closed','</xsl:text>
    <xsl:value-of select="$postname"/>
    <xsl:text>','','',NOW(),NOW(),'','glossary');
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
