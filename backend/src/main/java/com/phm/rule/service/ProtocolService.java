package com.phm.rule.service;

import com.phm.rule.entity.RuleProtocol;
import com.phm.rule.mapper.RuleQueryMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 采集协议查询。车型过滤走协议与车型关系，不看参数表上已废弃的 scope_cx。
 */
@Service
public class ProtocolService {

    private final RuleQueryMapper queryMapper;

    /**
     * @param queryMapper 跨表查询
     */
    public ProtocolService(RuleQueryMapper queryMapper) {
        this.queryMapper = queryMapper;
    }

    /**
     * 启用中的协议。传入车型时只返回挂了该车型的协议。
     *
     * @param cx 车型，空表示全部
     * @return 协议列表
     */
    public List<RuleProtocol> list(String cx) {
        String model = cx == null ? "" : cx.trim();
        return queryMapper.selectProtocols(model);
    }
}
