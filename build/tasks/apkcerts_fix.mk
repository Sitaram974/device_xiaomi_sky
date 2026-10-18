ifeq ($(TARGET_DEVICE),sky)
$(call intermediates-dir-for,PACKAGING,apkcerts)/$(TARGET_PRODUCT)-apkcerts-soong-doublecheck-stamp.txt:
	@mkdir -p $(dir $@) && rm -f $@ && touch $@
endif
