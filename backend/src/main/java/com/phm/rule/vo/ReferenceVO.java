package com.phm.rule.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 原子或命名组被谁引用，删除前给用户看。
 */
@Data
public class ReferenceVO {

    private String code;
    private String name;
    private int directFaults;
    private int inGroups;
    private int inBranches;
    private List<FaultBrief> faults = new ArrayList<FaultBrief>();
    private List<String> groups = new ArrayList<String>();

    /**
     * 引用方故障。
     */
    @Data
    public static class FaultBrief {
        private Long id;
        private String cx;
        private String ly;
        private String gzdm;
        private String gzmc;
        /** DIRECT 直接引用，GROUP 经命名组 */
        private String via;
    }
}
