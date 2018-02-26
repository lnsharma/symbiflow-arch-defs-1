ifneq (1,$(MUX_GEN))
$(error "Please define $$MUX_GEN=1 in your including Makefile.")
endif

# Check the MUX required configuration
# ------------------------------------------------------------------------
ifeq (,$(MUX_TYPE))
$(error "Please define $$MUX_TYPE in your including Makefile.")
endif

MUX_TYPE_VALID := 0
ifeq (routing,$(MUX_TYPE))
MUX_TYPE_VALID := 1
#$(warning "Generating *routing* mux.")

ifneq (,$(MUX_SUBCKT))
$(error "Can not use $$MUX_SUBCKT (=$(MUX_SUBCKT)) with routing mux.")
endif
endif

ifeq (logic,$(MUX_TYPE))
MUX_TYPE_VALID := 1
#$(warning "Generating *logic* mux.")
endif

ifeq (0,$(MUX_TYPE_VALID))
$(error "Unknown $$MUX_TYPE of $(MUX_TYPE) in your including Makefile.")
endif

ifeq (,$(MUX_NAME))
$(error "Please define $$MUX_NAME in your including Makefile.")
endif

ifeq (,$(MUX_WIDTH))
$(error "Please define $$MUX_WIDTH in your including Makefile.")
endif

# Split the input pins of the MUX and how to name them.
# ------------------------------------------------------------------------
ifneq (,$(MUX_INPUTS))
MUX_SPLIT_INPUTS ?= 1
ifneq (1,$(MUX_SPLIT_INPUTS))
$(error "$$MUX_INPUTS specified but $$MUX_SPLIT_INPUTS ($(MUX_SPLIT_INPUTS)) is not 1.")
endif
endif

MUX_SPLIT_INPUTS ?= 0
# Prevent accidentally trying to use $MUX_INPUT with MUX_SPLIT_INPUTS
ifeq (1,$(MUX_SPLIT_INPUTS))
ifneq (,$(MUX_INPUT))
$(error "Can not use $$MUX_INPUT with $$MUX_SPLIT_INPUTS ($(MUX_SPLIT_INPUTS)) set to 1.")
endif
endif

# Split the select pins of the MUX and what to call them.
# ------------------------------------------------------------------------
ifneq (,$(MUX_SELECTS))
MUX_SPLIT_SELECTS ?= 1
ifneq (1,$(MUX_SPLIT_SELECTS))
$(error "$$MUX_SELECTS specified but $$MUX_SPLIT_SELECTS ($(MUX_SPLIT_SELECTS)) is not 1.")
endif
endif

MUX_SPLIT_SELECTS ?= 0
# Prevent accidentally trying to use $MUX_SELECT with MUX_SPLIT_SELECTS
ifeq (1,$(MUX_SPLIT_SELECTS))
ifneq (,$(MUX_SELECT))
$(error "Can not use $$MUX_SELECT with $$MUX_SPLIT_SELECTS ($(MUX_SPLIT_SELECTS)) set to 1.")
endif
endif

# Work out the mux_gen command line
# ------------------------------------------------------------------------
MUX_GEN_CMD = $(realpath $(SELF_DIR)/../../utils/mux_gen.py)
MUX_GEN_LIB = $(realpath $(SELF_DIR)/../../utils/lib)
MUX_GEN_FILES = $(MUX_GEN_LIB)/*.py
MUX_GEN_OUTPUTS = $(MUX_OUTFILE).model.xml $(MUX_OUTFILE).pb_type.xml $(MUX_OUTFILE).sim.v

MUX_GEN_ARGS =
MUX_GEN_ARGS +=		--outdir 	$(dir $(INC_MAKEFILE))
ifneq (,$(MUX_OUTFILE))
MUX_GEN_ARGS +=		--outfilename 	$(MUX_OUTFILE)
endif
MUX_GEN_ARGS +=		--type 		$(MUX_TYPE)
MUX_GEN_ARGS +=		--width 	$(MUX_WIDTH)
MUX_GEN_ARGS +=		--name-mux 	$(MUX_NAME)

ifneq (,$(MUX_COMMENT))
MUX_GEN_ARGS +=		--comment	"$(MUX_COMMENT)"
endif

ifneq (,$(MUX_OUT))
MUX_GEN_ARGS +=		--name-out	$(MUX_OUT)
endif

ifeq (1,$(MUX_SPLIT_INPUTS))
MUX_GEN_ARGS +=		--split-inputs
endif

ifneq (,$(MUX_INPUTS))
MUX_GEN_ARGS += 	--name-inputs	$(MUX_INPUTS)
endif

ifneq (,$(MUX_INPUT))
MUX_GEN_ARGS +=		--name-input	$(MUX_INPUT)
endif

ifeq (1,$(MUX_SPLIT_SELECTS))
MUX_GEN_ARGS +=		--split-selects
endif

ifneq (,$(MUX_SELECTS))
MUX_GEN_ARGS +=		--name-selects	$(MUX_SELECTS)
endif

ifneq (,$(MUX_SELECT))
MUX_GEN_ARGS +=		--name-select	$(MUX_SELECT)
endif

ifneq (,$(MUX_SUBCKT))
MUX_GEN_ARGS +=		--subckt	$(MUX_SUBCKT)
endif

MUX_GEN_FULL_CMD = $(MUX_GEN_CMD) $(MUX_GEN_ARGS)

#$(warning "MUX_GEN_FULL_CMD = '$(MUX_GEN_FULL_CMD)'")

# Actual make targets
# ------------------------------------------------------------------------

# Depend on the libraries that mux generator command uses
#$(MUX_DEPS): $(MUX_GEN_LIB)/*.py

$(MUX_GEN_OUTPUTS): $(SELF_DIR)/deps.mk
$(MUX_GEN_OUTPUTS): $(SELF_DIR)/mux.mk

# Depend on the config makefile
$(MUX_GEN_OUTPUTS): $(call ALL,$(INC_MAKEFILE))

# Depend on the mux generator command
$(MUX_GEN_OUTPUTS): $(MUX_GEN_CMD)

$(MUX_GEN_OUTPUTS):
	@echo "Generating $(MUX_TYPE) MUX $(MUX_NAME)"
	@$(MUX_GEN_FULL_CMD)

clean: mux_clean
mux_clean:
	rm -f $(MUX_GEN_OUTPUTS) $(MUX_DEPS)

all: $(MUX_GEN_OUTPUTS)

.PHONY: clean
