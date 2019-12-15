<#include "/abstracted/common.ftl">
<#list this.holds! as otherEntity,mtm>
    <#assign entityFeature=mtm.getEntityFeature(this.entityId)>
    <#if !entityFeature.addRemove>
        <#continue>
    </#if>
    <#assign otherCName=otherEntity.className?capFirst>
    <#assign othercName=otherEntity.className?uncapFirst>
    <#assign otherId=otherEntity.pkField.jfieldName>
    <#--定义代码内容-->
    <#assign code>
<template>
  <el-dialog title="添加移除${otherEntity.title}" :visible.sync="formVisible" @close="handleClose">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <el-form ref="dataForm" :model="form" :inline="true"
                 label-position="right" size="small"
                 label-width="120px">
          <el-form-item label="${otherEntity.title}:">
            <el-select v-model="form.${othercName}List"
                       style="width:400px;" placeholder="请输入关键词"
                       remote :remote-method="findOptions"
                       :loading="optionsLoading"
                       filterable clearable multiple>
              <el-option v-for="item in options.${othercName}"
                         :key="item.key"
                         :label="item.value"
                         :value="item.key">
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleAdd${otherCName}">添加</el-button>
          </el-form-item>
        </el-form>
      </div>
      <el-table :data="form.${othercName}ListRaw" style="width: 100%;"
                size="mini" border>
        <el-table-column label="${otherEntity.titleField.fieldDesc}" prop="${otherEntity.titleField.jfieldName}"></el-table-column>
        <el-table-column label="操作" align="center" width="150"
                         class-name="small-padding fixed-width" fixed="right">
          <template slot-scope="{row}">
            <el-button type="danger" size="mini"
                       @click="handleDeleteSingle(row)" class="table-inner-button">移除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </el-dialog>
</template>

<script>
import ${this.className}Api from '@/api/${this.className}'
import ${othercName}Api from '@/api/${othercName}'

export default {
  name: '${otherCName}Setting',
  data() {
    return {
      optionsLoading: false,
      options: {
        ${othercName}: []
      },
      form: {
        ${this.id}: null,
        ${othercName}List: [],
        ${othercName}ListRaw: []
      },
      formUpdated: false,
      formVisible: false
    }
  },
  methods: {
    /**
     * 显示表单
     */
    handleShow(${this.id}) {
      this.form.${this.id} = ${this.id}
      this.form.${othercName}List = []
      this.fetchList()
        .then(() => {
          this.formVisible = true
        })
    },
    findOptions(matchValue) {
      // 输入长度小于2，则不加载
      if (!matchValue || matchValue.length < 2) {
        return
      }
      this.optionsLoading = true
      ${othercName}Api.findOptions({ matchValue })
        .then(data => { this.options.${othercName} = data })
        .finally(() => {
          this.optionsLoading = false
        })
    },
    /**
     * 查询表格数据
     */
    fetchList() {
      return ${this.className}Api.fetch${otherCName}List(this.form.${this.id})
        .then(data => {
          this.form.${othercName}ListRaw = data
        })
    },
    /**
     * 执行添加操作
     */
    handleAdd${otherCName}() {
      this.$refs['dataForm'].validate()
        .then(() => ${this.className}Api.add${otherCName}(this.form.${this.id}, this.form.${othercName}List))
        .then(data => {
          this.$common.showMsg('success', '添加成功')
          this.formUpdated = true
          this.form.${othercName}List = []
          this.fetchList()
        })
    },
    /**
     * 移除单个
     */
    handleDeleteSingle(row) {
      return this.$common.confirm('是否确认移除')
        .then(() => ${this.className}Api.remove${otherCName}(this.form.${this.id}, [row.${otherId}]))
        .then(() => {
          this.$common.showMsg('success', '移除成功')
          this.formUpdated = true
          this.fetchList()
        })
    },
    /**
     * 表单关闭时触发
     */
    handleClose() {
      if (this.formUpdated) {
        this.$emit('updated')
      }
    }
  }
}
</script>

    </#assign>
    <#--往当前目录输出额外代码文件-->
    <@justCall this.writeAdditionalFile("${othercName}AddRemove.vue",code)/>
</#list>
<#--不需要输出当前文件-->
<@call this.skipCurrent()/>
