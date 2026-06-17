//RESPECT ALPHABETICAL ORDER WHEN ADDING NEW CONSTANTS
public with sharing class Constants {
  
  public static final CaseConstants CASES {
    get { return CaseConstants.getInstance(); }
  }

  public static final EquipmentConstants EQUIPMENT {
    get { return EquipmentConstants.getInstance(); }
  }

  public static final HttpConstants HTTP {
    get { return HttpConstants.getInstance(); }
  }

  public static final PartsQuoteConstants PARTS_QUOTE {
    get { return PartsQuoteConstants.getInstance(); }
  }

  public static final UserConstants USER {
    get { return UserConstants.getInstance(); }
  }

  public static final WorkOrderConstants WORK_ORDER {
    get { return WorkOrderConstants.getInstance(); }
  }
  
  public static final WorkOrderLineItemConstants WORK_ORDER_LINE_ITEM {
    get { return WorkOrderLineItemConstants.getInstance(); }
  }

}