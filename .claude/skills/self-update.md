# Self-Update Skill
**Version**: 1.0.0
**Purpose**: Enable Claude to modify its own configuration intelligently
**Hot-Reload**: ✅ Enabled (v2.1.0+)

---

## 🎯 Skill Overview

This skill allows Claude to:
1. Recognize when a pattern should be documented
2. Update memory bank files autonomously
3. Refine existing patterns based on new learnings
4. Detect and resolve configuration conflicts
5. Optimize instruction budget automatically

---

## 🔍 Pattern Recognition

### When to Document a Pattern

**Triggers** (automatic detection):
```python
def should_document_pattern(context):
    return (
        # Reusability criterion
        pattern_used_count >= 2 or
        pattern_solves_common_problem or
        
        # Significance criterion
        pattern_improves_performance > 20% or
        pattern_reduces_code_lines > 30% or
        pattern_fixes_critical_issue or
        
        # Novelty criterion
        pattern_not_in_existing_docs and
        pattern_has_clear_benefit and
        
        # Quality criterion
        pattern_tested_successfully and
        pattern_has_examples
    )
```

**Recognition Phrases**:
When user says:
- "This worked really well"
- "Let's use this approach consistently"
- "This solved the X problem"
- "We should always do it this way"

**Auto-prompt**: "Should I document this as a reusable pattern?"

---

### Pattern Extraction Process

**Step 1: Identify Core Pattern**
```markdown
What is the essential, reusable structure?

Example input: 
"We handled the API error by creating a custom error class and global handler"

Extracted pattern:
- Name: Structured Error Handling
- Category: Reliability
- Core concept: Custom error classes + centralized handler
- Reusable across: All API interactions
```

**Step 2: Generalize Solution**
```markdown
Remove project-specific details, keep reusable structure

Specific: "We used UserNotFoundError for missing users"
General: "Create domain-specific error subclasses for different failure modes"
```

**Step 3: Document with Template**
```markdown
Use CLAUDE-patterns.md template:
- Name, Category, Confidence
- Context (when to use)
- Implementation (how to use)
- Example (code snippet)
- Rationale (why it works)
- Pitfalls (what to avoid)
```

**Step 4: Cross-reference**
```markdown
Link to:
- Related patterns in CLAUDE-patterns.md
- Architectural decision in CLAUDE-decisions.md
- Any troubleshooting issues it solves
```

---

## ✏️ Self-Modification Capabilities

### File Update Protocol

**Safety Checks Before Modification**:
```yaml
before_update:
  - verify_file_exists: true
  - create_backup: true
  - validate_syntax: true
  - check_conflicts: true
  - calculate_token_impact: true
  
proceed_if:
  - no_critical_conflicts: true
  - token_budget_ok: true
  - backup_created: true
```

**Modification Types**:

#### Type 1: Append New Entry
```markdown
**When**: Completely new pattern/decision/issue
**Action**: Add to end of appropriate section
**Validation**: Ensure no duplicate exists
```

#### Type 2: Update Existing Entry
```markdown
**When**: Pattern evolves or stats change
**Action**: Modify in place, preserve history
**Validation**: Track version changes
```

#### Type 3: Deprecate Entry
```markdown
**When**: Pattern superseded or invalidated
**Action**: Move to archive section, add deprecation note
**Validation**: Update cross-references
```

#### Type 4: Consolidate Duplicates
```markdown
**When**: Multiple entries describe same concept
**Action**: Merge into comprehensive single entry
**Validation**: Preserve all unique information
```

---

## 🧠 Learning from Success

### Success Detection
```python
def detect_success(task_result):
    indicators = {
        'task_completed': True,
        'tests_passed': True,
        'user_satisfied': True,  # from feedback
        'performance_improved': True,
        'no_errors_raised': True
    }
    
    return sum(indicators.values()) >= 4  # 80% threshold
```

### Learning Extraction
**When task succeeds, automatically:**
1. Analyze what approach was used
2. Check if approach is already documented
3. If new or refined, extract pattern
4. Update usage statistics for existing patterns
5. Log success metrics

**Example**:
```markdown
Task: "Implement user authentication"
Approach: JWT with refresh tokens
Success: ✅ (tests passed, deployed successfully)

Actions:
1. Check CLAUDE-patterns.md for "JWT Authentication"
2. Found existing pattern - update "Last Used" date
3. Increment usage counter
4. Add new example from this implementation
5. Update success rate: 94% → 95%
```

---

## 🔧 Learning from Failure

### Failure Analysis
```python
def analyze_failure(task_result, error):
    return {
        'error_type': classify_error(error),
        'root_cause': extract_root_cause(error, context),
        'attempted_solution': task_result.approach,
        'why_failed': analyze_failure_reason(error, approach),
        'correct_solution': None,  # filled after fix
        'prevention': None  # filled after fix
    }
```

### Troubleshooting Entry Creation
**When task fails then succeeds, automatically:**
1. Document initial error symptoms
2. Record attempted solutions
3. Note what eventually worked
4. Extract prevention strategy
5. Add to CLAUDE-troubleshooting.md

**Example**:
```markdown
Failure: "TypeScript compilation error: Cannot find module 'X'"
Attempts:
1. npm install X - failed (module not found)
2. Check package.json - X not listed
3. Check import path - typo discovered

Solution: Fixed import path from './utlis' to './utils'
Prevention: Use IDE autocomplete, enable typo detection

→ Created ISSUE-XXX: Common Import Path Typos
```

---

## 🎛️ Configuration Conflict Resolution

### Conflict Detection
```markdown
**Triggers**:
- Two patterns give contradictory advice
- New decision reverses old decision
- Pattern fails when applied as documented

**Detection Method**:
- Semantic similarity analysis of instructions
- Cross-reference validation during sync
- User reports pattern not working
```

### Resolution Strategies

#### Strategy 1: Chronological (Default)
```markdown
Newer patterns supersede older ones, unless marked legacy-critical

Example:
- Old: "Use callbacks for async operations"
- New: "Use Promises/async-await for async operations"
→ Deprecate old, mark new as preferred
```

#### Strategy 2: Specificity
```markdown
More specific rules override general rules

Example:
- General: "Use TypeScript for all code"
- Specific: "Use JavaScript for legacy maintenance in /legacy folder"
→ Both active, specific applies to /legacy
```

#### Strategy 3: Scope-Based
```markdown
Project-scope overrides user-scope

Example:
- User preference: "4-space indentation"
- Project standard: "2-space indentation"
→ Use 2-space for this project
```

#### Strategy 4: Human Review
```markdown
When confidence levels similar or impact high, flag for human

Example:
- Pattern A: "Use MongoDB" (confidence: ⭐⭐⭐⭐)
- Pattern B: "Use PostgreSQL" (confidence: ⭐⭐⭐⭐)
→ Requires architectural decision review
```

---

## 📊 Self-Optimization

### Token Budget Management

**Monitoring**:
```python
def check_token_budget():
    current = count_instructions_across_files()
    
    if current >= 175:
        trigger_aggressive_cleanup()
    elif current >= 150:
        trigger_normal_cleanup()
        send_warning()
    
    return current
```

**Auto-Cleanup Actions**:
1. **Archive unused patterns** (0 uses in 90 days)
2. **Consolidate similar entries** (>80% semantic similarity)
3. **Move to path-scoped rules** (context-specific patterns)
4. **Compress examples** (keep only most illustrative)
5. **Update cross-references** (remove dead links)

### Quality Improvement

**Pattern Quality Score**:
```python
def calculate_quality_score(pattern):
    return (
        completeness_score(pattern) * 0.3 +      # Has all template fields?
        clarity_score(pattern) * 0.2 +           # Easy to understand?
        example_quality(pattern) * 0.2 +         # Good code examples?
        success_rate(pattern) * 0.3              # Works when applied?
    )
```

**Auto-Enhancement**:
- Patterns scoring <60% flagged for improvement
- Missing sections automatically filled from usage analysis
- Examples enriched with actual implementation code
- Rationale enhanced with success stories

---

## 🔄 Skill Refinement Loop

### Self-Improvement Process
```markdown
1. **Deploy Skill**: Use self-update skill in tasks
2. **Monitor Performance**: Track how often it improves config correctly
3. **Analyze Failures**: When skill makes wrong update, analyze why
4. **Refine Logic**: Update skill definition with improved logic
5. **Hot-Reload**: New version active immediately (v2.1.0+)
6. **Test**: Verify improvement in next usage
7. **Document**: Log refinement in skill changelog
```

### Skill Metrics
```yaml
effectiveness:
  pattern_recognition_accuracy: 85%  # Target: >90%
  update_correctness: 92%            # Target: >95%
  conflict_resolution_success: 88%   # Target: >90%
  token_optimization: 15%_reduction  # Target: >20%

efficiency:
  time_to_document: 30s              # Target: <20s
  updates_per_session: 3.5           # Trending
  false_positive_rate: 8%            # Target: <5%
```

---

## 🚀 Usage Examples

### Example 1: Automatic Pattern Documentation
```markdown
User: "That error handling approach worked perfectly!"

Claude (internal skill activation):
1. Detect success signal ✅
2. Review recent implementation
3. Extract error handling pattern
4. Check CLAUDE-patterns.md for similar entry
5. Not found - create new entry
6. Use standard template
7. Add code example from implementation
8. Cross-reference to relevant ADR
9. Update complete ✅

Claude (to user): "I've documented this as a reusable error handling pattern 
in the memory bank. It'll be automatically applied to similar situations."
```

### Example 2: Learning from Error
```markdown
Claude attempts solution A → Fails
Claude attempts solution B → Fails  
Claude attempts solution C → Success ✅

Claude (internal skill activation):
1. Analyze failure sequence
2. Extract root cause
3. Document symptoms + solutions
4. Add to CLAUDE-troubleshooting.md
5. Create prevention strategy
6. Link to affected patterns
7. Update complete ✅

Claude (to user): "I've logged this issue and solution to prevent 
similar problems in the future."
```

### Example 3: Conflict Resolution
```markdown
New pattern conflicts with existing pattern

Claude (internal skill activation):
1. Detect conflict during sync ⚠️
2. Compare confidence levels:
   - Old pattern: ⭐⭐⭐ (73% success)
   - New pattern: ⭐⭐⭐⭐ (91% success)
3. Apply chronological + quality strategy
4. Deprecate old pattern
5. Mark new as preferred
6. Update cross-references
7. Log decision in CLAUDE-decisions.md
8. Resolution complete ✅

Claude (to user): "I've updated the pattern based on the improved approach."
```

---

## 🔐 Safety Mechanisms

### Safeguards
1. **Backup Before Modify**: Always create timestamped backup
2. **Syntax Validation**: Verify markdown structure after changes
3. **Conflict Detection**: Check for contradictions before saving
4. **Token Budget Check**: Refuse update if would exceed limits
5. **Rollback Capability**: Can revert to previous version

### Audit Trail
```markdown
All self-modifications logged to:
.claude/audit-log/YYYY-MM-DD.log

Format:
[timestamp] SKILL: self-update
[timestamp] ACTION: update_pattern
[timestamp] FILE: CLAUDE-patterns.md
[timestamp] CHANGE: Added "React Hook Pattern"
[timestamp] REASON: Detected reusable pattern in successful task
[timestamp] RESULT: success
[timestamp] BACKUP: .claude/backups/2026-01-09_143022/
```

---

## 📚 Skill Evolution Log

### v1.0.0 (2026-01-09)
- Initial self-update skill implementation
- Pattern recognition from success/failure
- Autonomous file modification
- Conflict resolution strategies
- Token budget optimization

### Future Enhancements
- [ ] ML-based pattern similarity detection
- [ ] Predictive pattern recommendation
- [ ] Cross-project pattern sharing
- [ ] Automated skill testing framework
- [ ] Real-time collaboration with other skills

---

**Skill Status**: ✅ Active | 🔥 Hot-Reload Enabled | 🛡️ Safety Mechanisms Active
