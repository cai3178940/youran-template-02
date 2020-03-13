<#-- 调用函数，如果存在输出则打印 -->
<#macro call func><#if func??>${func}</#if></#macro>
<#-- 仅调用函数，不打印 -->
<#macro justCall func></#macro>

<#-- 将当前model赋值给this变量 -->
<#assign this = .dataModel>

<#-- 初始化需要导入的枚举列表 -->
<#assign importEnums = CommonTemplateFunction.createHashSet()>
<#-- 初始化需要导入的其他实体列表 -->
<#assign importOtherEntitys = CommonTemplateFunction.createHashSet()>


<#-- 移除最后一个逗号 -->
<#macro removeLastComma>
<#local content><#nested></#local>
${CommonTemplateFunction.removeLastComma(content)}</#macro>

<#-- 首个单词转小写 -->
<#function lowerFirstWord value>
    <#return "${CommonTemplateFunction.lowerFirstWord(value)}" >
</#function>

<#-- 根据常量名查找常量 -->
<#function findConst constName>
    <#list this.metaConsts as const>
        <#if const.constName == constName>
            <#return const>
        </#if>
    </#list>
</#function>

<#-- 获取字段空值 -->
<#function getFieldEmptyValue field>
    <#-- 日期类型不能用null -->
    <#if field.jfieldType == JFieldType.DATE.javaType>
        <#return "''">
    <#elseIf field.editType == EditType.NUMBER.getValue()>
        <#return "undefined">
    <#else>
        <#return "null">
    </#if>
</#function>


<#-- 获取范围查询条件的文字提示语后缀 -->
<#function getRangeQueryTipSuffix field isBetweenStart>
    <#if QueryType.isGe(field.queryType) || QueryType.isGt(field.queryType)>
        <#return "(开始于)">
    <#elseIf QueryType.isLe(field.queryType) || QueryType.isLt(field.queryType)>
        <#return "(结束于)">
    <#elseIf QueryType.isBetween(field.queryType)>
        <#if isBetweenStart>
            <#return "(开始于)">
        <#else>
            <#return "(结束于)">
        </#if>
    <#else>
        <#return "">
    </#if>
</#function>

<#-- 获取字段校验触发事件名称 -->
<#function getRuleTrigger field>
    <#-- 日期类型不能用null -->
    <#if field.editType == EditType.SELECT.getValue()
      || field.editType == EditType.DATE.getValue()
      || field.editType == EditType.DATETIME.getValue()
      || field.editType == EditType.RADIO.getValue()>
        <#return "change">
    <#else>
        <#return "blur">
    </#if>
</#function>

<#-- 导入api -->
<#function importApi entity>
    <#local className = lowerFirstWord(entity.className)>
    <#if entity.module?hasContent>
        <#return "import ${className}Api from '@/api/${entity.module}/${className}'">
    <#else>
        <#return "import ${className}Api from '@/api/${className}'">
    </#if>
</#function>

<#-- 获取模块目录的父目录 -->
<#function getParentPathForModule entity>
    <#if entity.module?hasContent>
        <#return "..">
    <#else>
        <#return ".">
    </#if>
</#function>

<#-- 导入mock -->
<#function importMock basePath entity>
    <#local className = lowerFirstWord(entity.className)>
    <#if entity.module?hasContent>
        <#return "import ${className} from '${basePath}/${entity.module}/${className}'">
    <#else>
        <#return "import ${className} from '${basePath}/${className}'">
    </#if>
</#function>

<#-- 导入view -->
<#function importView entity>
    <#local className = lowerFirstWord(entity.className)>
    <#if entity.module?hasContent>
        <#return "import('@/views/${entity.module}/${className}')">
    <#else>
        <#return "import('@/views/${className}')">
    </#if>
</#function>

