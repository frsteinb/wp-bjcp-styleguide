<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
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



  <xsl:template match="/styleguide">
    <exsl:document href="-" method="text" encoding="UTF-8"
                   omit-xml-declaration="yes">
      <xsl:text>DELETE FROM `wp_posts` WHERE post_content LIKE '<![CDATA[<!-- auto-generated bjcp glossary post-->]]>%';
</xsl:text>
      <xsl:apply-templates select="( //class | //category | //subcategory | //specialty )"/>
    </exsl:document>
  </xsl:template>

  <xsl:template match="specialty" mode="classification">
    <xsl:apply-templates select=".." mode="classification"/>
    <xsl:text>- - - - Specialty </xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="subcategory" mode="classification">
    <xsl:apply-templates select=".." mode="classification"/>
    <xsl:text>- - - Subcategory </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>)</xsl:text>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="category" mode="classification">
    <xsl:apply-templates select=".." mode="classification"/>
    <xsl:text>- - Category </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="name"/>
    <xsl:text>)</xsl:text>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="class" mode="classification">
    <xsl:text>- Class </xsl:text>
    <xsl:value-of select="concat(translate(substring(@type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(@type,2))"/>
    <xsl:text><![CDATA[<br/>]]></xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="section">
    <xsl:text><![CDATA[<dt>]]></xsl:text>
    <xsl:value-of select="concat(translate(substring(local-name(.),1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(local-name(.),2))"/>
    <xsl:text><![CDATA[</dt>]]></xsl:text>
    <xsl:text><![CDATA[<dd>]]></xsl:text>
    <xsl:call-template name="subst">
      <xsl:with-param name="text" select="./text()"/>
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
      <xsl:value-of select="./name"/>
      <xsl:if test="position() = last()">
        <xsl:text><![CDATA[</dd>]]></xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="specialties">
    <xsl:if test="entry_instructions">
      <xsl:text><![CDATA[<dt>Specialty Entry Instructions</dt>]]></xsl:text>
      <xsl:text><![CDATA[<dd>]]></xsl:text>
      <xsl:apply-templates select="entry_instructions" mode="instr"/>
      <xsl:text><![CDATA[</dd>]]></xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="stats">
    <xsl:text><![CDATA[<table>]]></xsl:text>
    <xsl:if test="og/@flexible = 'false'">
      <xsl:text><![CDATA[<tr><td>Stammwürze</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(og/low),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(og/high),'0.0')"/>
      <xsl:text> °P</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text>OG </xsl:text>
      <xsl:value-of select="og/low"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="og/high"/>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="fg/@flexible = 'false'">
      <xsl:text><![CDATA[<tr><td>Restextrakt</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(fg/low),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:sgToPlato(fg/high),'0.0')"/>
      <xsl:text> GG%</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text>FG </xsl:text>
      <xsl:value-of select="fg/low"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="fg/high"/>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="abv/@flexible = 'false'">
      <xsl:text><![CDATA[<tr><td>Alkohol</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(abv/low,'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(abv/high,'0.0')"/>
      <xsl:text> %vol</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="ibu/@flexible = 'false'">
      <xsl:text><![CDATA[<tr><td>Bittere</td><td>]]></xsl:text>
      <xsl:value-of select="ibu/low"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="ibu/high"/>
      <xsl:text> IBU</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:if test="og/@flexible = 'false'">
	<xsl:text>( </xsl:text>
	<xsl:value-of select="brew:bitterWort(ibu/low, og/high)"/>
	<xsl:text> - </xsl:text>
	<xsl:value-of select="brew:bitterWort(ibu/high, og/low)"/>
	<xsl:text> )</xsl:text>
      </xsl:if>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:if test="srm/@flexible = 'false'">
      <xsl:text><![CDATA[<tr><td>Farbe</td><td>]]></xsl:text>
      <xsl:value-of select="format-number(brew:srmToEbc(srm/low),'0.0')"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="format-number(brew:srmToEbc(srm/high),'0.0')"/>
      <xsl:text> EBC</xsl:text>
      <xsl:text><![CDATA[</td><td>]]></xsl:text>
      <xsl:value-of select="srm/low"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="srm/high"/>
      <xsl:text> SRM</xsl:text>
      <xsl:text><![CDATA[</td></tr>]]></xsl:text>
    </xsl:if>
    <xsl:text><![CDATA[</table>]]></xsl:text>
  </xsl:template>

  <xsl:template match="entry_instructions" mode="instr">
    <xsl:apply-templates select="text() | *" mode="asis"/>
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

  <xsl:template match="class | category | subcategory | specialty">
    <xsl:variable name="id">
      <xsl:choose>
	<xsl:when test="@type">
	  <xsl:value-of select="@type"/>
	</xsl:when>
	<xsl:when test="@id">
	  <xsl:value-of select="@id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="name"/>
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
          <xsl:value-of select="name"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="postname">bjcp-<xsl:value-of select="translate($id,'ABCDEFGHIJKLMNOPQRSTUVWXYZ ','abcdefghijklmnopqrstuvwxyz-')"/></xsl:variable>
    <xsl:text>INSERT INTO `wp_posts` (post_author,post_date,post_date_gmt,post_content,post_title,post_excerpt,comment_status,ping_status,post_name,to_ping,pinged,post_modified,post_modified_gmt,post_content_filtered,post_type) VALUES (1,NOW(),NOW(),'<![CDATA[<!-- auto-generated bjcp glossary post-->]]></xsl:text>
<!--
    <xsl:choose>
      <xsl:when test="local-name(.) = 'class'">
        <xsl:value-of select="translate(substring(@type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <xsl:value-of select="substring(@type,2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name"/>
      </xsl:otherwise>
    </xsl:choose>
-->
    <xsl:text><![CDATA[</h2><dt>Classification</dt><dd>]]></xsl:text>
    <xsl:apply-templates select="." mode="classification"/>
    <xsl:text><![CDATA[</dd>]]></xsl:text>

    <xsl:apply-templates select="stats"/>

    <xsl:apply-templates select="notes" mode="section"/>
    <xsl:apply-templates select="aroma" mode="section"/>
    <xsl:apply-templates select="appearance" mode="section"/>
    <xsl:apply-templates select="flavor" mode="section"/>
    <xsl:apply-templates select="mouthfeel" mode="section"/>
    <xsl:apply-templates select="impression" mode="section"/>
    <xsl:apply-templates select="comments" mode="section"/>
    <xsl:apply-templates select="history" mode="section"/>
    <xsl:apply-templates select="ingredients" mode="section"/>
    <xsl:apply-templates select="comparison" mode="section"/>
    <xsl:apply-templates select="examples" mode="section"/>
    <xsl:apply-templates select="tags" mode="section"/>

    <xsl:apply-templates select="." mode="specialties"/>

    <xsl:apply-templates select="." mode="children"/>

    <xsl:text></xsl:text><xsl:text><![CDATA[<p style="font-size: 70%;">Diese Informationen entstammen einer XML-Form der BJCP Style Guidelines, die per <a href="https://github.com/meanphil/bjcp-guidelines-2015">GitHub</a> öffentlich verfügbar ist. Ich bereite diese Daten hier lediglich für meine persönlichen und nicht gewerblichen Zwecke auf, um sie leichter lesbar zu machen und Werte mit den in Deutschland gebräuchlicheren Einheiten darzustellen.</p>]]></xsl:text>

    <xsl:text>','</xsl:text>
    <xsl:value-of select="$title"/>
    <xsl:text>','','closed','closed','</xsl:text>
    <xsl:value-of select="$postname"/>
    <xsl:text>','','',NOW(),NOW(),'','glossary');
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
