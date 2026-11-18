package com.phm.rule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.phm.rule.entity.RuleProtocol;
import org.apache.ibatis.annotations.Mapper;

/**
 * 协议表的基础访问。按车型过滤的列表在 RuleQueryMapper。
 */
@Mapper
public interface RuleProtocolMapper extends BaseMapper<RuleProtocol> {
}
