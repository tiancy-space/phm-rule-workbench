package com.phm.rule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.phm.rule.entity.DictItem;
import org.apache.ibatis.annotations.Mapper;

/**
 * DictItem 表的基础访问。常规查询走 MyBatis-Plus，物理删除和跨表查询在 RuleQueryMapper。
 */
@Mapper
public interface DictItemMapper extends BaseMapper<DictItem> {
}
