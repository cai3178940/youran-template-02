<#include "/abstracted/common.ftl">
<#include "/abstracted/commonForChart.ftl">
<template>
  <div :class="className" :style="{height:height,width:width}">
    <el-table v-loading="listLoading" :data="list"
              border stripe style="width: 100%;">

      <el-table-column label="主键"
                       prop="userId"
                       align="center">
        <template slot-scope="{row}">
          <span>{{ row.userId }}</span>
        </template>
      </el-table-column>
      <el-table-column label="名称"
                       prop="name"
                       align="center">
        <template slot-scope="{row}">
          <span>{{ row.name }}</span>
        </template>
      </el-table-column>
      <el-table-column label="性别"
                       prop="sex"
                       align="center" width="150">
        <template slot-scope="{row}">
          <span>{{ row.sex | findEnumLabel(enums.sex) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="注册时间"
                       prop="regTime"
                       align="center" width="100">
        <template slot-scope="{row}">
          <span>{{ row.regTime }}</span>
        </template>
      </el-table-column>
      <el-table-column label="部门名称"
                       prop="deptName"
                       align="center">
        <template slot-scope="{row}">
          <span>{{ row.deptName }}</span>
        </template>
      </el-table-column>
    </el-table>
    <pagination v-show="total>0" :total="total" :page.sync="query.page"
                :limit.sync="query.limit" @pagination="doQueryList"/>
  </div>
</template>

<script>
import threeTableApi from '@/api/system/threeTable'
import Pagination from '@/components/Pagination'
import enums from '@/utils/enums'
import resize from './mixins/resize'

export default {
  name: 'ThreeTable',
  mixins: [resize],
  components: {
    Pagination
  },
  props: {
    className: {
      type: String,
      default: 'threeTable'
    },
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    }
  },
  filters: {
    findEnumLabel: enums.findEnumLabel
  },
  data() {
    return {
      enums: {
        sex: enums.getSex()
      },
      list: [],
      total: 0,
      listLoading: true,
      query: {
        page: 1,
        limit: 10
      }
    }
  },
  created() {
    this.doQueryList({ page: 1 })
  },
  methods: {
    /**
     * 执行列表查询
     */
    doQueryList({ page, limit }) {
      if (page) {
        this.query.page = page
      }
      if (limit) {
        this.query.limit = limit
      }
      this.listLoading = true
      return threeTableApi.fetchList(this.query)
        .then(data => {
          this.list = data.list
          this.total = data.total
        })
        .finally(() => {
          this.listLoading = false
        })
    }
  }
}
</script>
