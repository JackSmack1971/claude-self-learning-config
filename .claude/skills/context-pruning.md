# Context Pruning Skill
**Version**: 1.0.0
**Purpose**: Intelligent cleanup of memory bank to maintain optimal token budget
**Hot-Reload**: ✅ Enabled (v2.1.0+)

---

## 🎯 Skill Overview

This skill automatically manages the instruction budget by:
1. Detecting when token limit approaches
2. Identifying consolidation opportunities
3. Archiving obsolete information
4. Optimizing cross-references
5. Maintaining pattern quality

---

## 🔍 Token Budget Monitoring

### Threshold Detection
```python
class TokenBudget:
    HEALTHY = 0-149      # No action needed
    WARNING = 150-174    # Start optimization
    CRITICAL = 175-199   # Aggressive cleanup
    EXCEEDED = 200+      # Block new additions
    
def check_budget():
    current = count_all_instructions()
    
    if current >= 200:
        return 'EXCEEDED'
    elif current >= 175:
        return 'CRITICAL'
    elif current >= 150:
        return 'WARNING'
    else:
        return 'HEALTHY'
```

### Instruction Counting
```markdown
**What counts as an instruction:**
- Pattern entries in CLAUDE-patterns.md
- Decision records in CLAUDE-decisions.md
- Active troubleshooting entries
- Skill definitions
- Agent configurations
- Path-scoped rules

**What doesn't count:**
- Comments and metadata
- Archived content
- Backup files
- Log entries
```

---

## 🧹 Cleanup Strategies

### Strategy 1: Archive Unused Patterns
**Trigger**: Pattern not used in 90+ days
**Action**: Move to archive section
**Preservation**: Full content retained for historical reference

```markdown
**Identification**:
Check "Last Used" date in each pattern entry

**Process**:
1. Find patterns with Last Used > 90 days ago
2. Verify zero usage in metrics
3. Move to "Archived Patterns" section
4. Update cross-references
5. Add archive metadata (date, reason)

**Recovery**:
Archived patterns can be restored if needed again
```

---

### Strategy 2: Consolidate Similar Patterns
**Trigger**: >80% semantic similarity between patterns
**Action**: Merge into comprehensive single entry
**Preservation**: All unique information retained

```markdown
**Identification**:
- Analyze pattern descriptions for overlap
- Check if examples demonstrate same concept
- Verify use cases are similar

**Merging Process**:
1. Choose most complete entry as base
2. Extract unique content from duplicates
3. Combine examples (keep best 2-3)
4. Merge usage statistics
5. Update confidence based on combined data
6. Delete duplicate entries
7. Redirect cross-references

**Quality Check**:
Merged pattern must be clearer than originals
```

---

### Strategy 3: Path-Scope Conversion
**Trigger**: Pattern applies only to specific file types/directories
**Action**: Move to path-scoped rule
**Effect**: Only loads when working with matching files

```markdown
**Identification**:
Patterns that contain phrases like:
- "For backend code..."
- "In the /api directory..."
- "When working with React components..."

**Conversion**:
1. Extract context-specific rule
2. Create .claude/rules/[path]/*.md file
3. Remove from global CLAUDE-patterns.md
4. Add path-scoping metadata
5. Test that it loads correctly

**Example**:
Global: "Always use async/await in API handlers"
→ Path-scoped: .claude/rules/api/**/*.md

**Token Savings**: 
Pattern only loads when needed, not globally
```

---

### Strategy 4: Compress Examples
**Trigger**: Pattern has >3 code examples
**Action**: Keep only most illustrative ones
**Preservation**: Other examples moved to separate file

```markdown
**Selection Criteria**:
Keep examples that:
1. Show the most common use case
2. Demonstrate a tricky edge case
3. Are shortest while still clear

**Compression**:
1. Identify redundant examples
2. Choose best representatives (max 3)
3. Move others to .claude/examples/[pattern-name].md
4. Add link to full examples
5. Reduce inline code

**Token Savings**:
~30% reduction per pattern with many examples
```

---

### Strategy 5: Remove Dead Cross-References
**Trigger**: Links to deleted or moved content
**Action**: Clean up broken links
**Effect**: Improved readability, fewer tokens

```markdown
**Detection**:
1. Parse all markdown links
2. Verify target exists
3. Check if target is archived
4. Identify circular references

**Cleanup**:
1. Remove links to deleted content
2. Update links to moved content
3. Simplify circular reference chains
4. Add validation to prevent future breaks

**Automation**:
Run link validation during sync process
```

---

## 🎛️ Cleanup Modes

### Normal Mode (150-174 tokens)
**Goal**: Optimize without losing content

```yaml
actions:
  - archive_unused_patterns: >90 days
  - consolidate_duplicates: >85% similarity
  - compress_examples: >3 examples per pattern
  - cleanup_links: broken references only
  
target_reduction: 10-15%
estimated_time: 30 seconds
```

### Aggressive Mode (175+ tokens)
**Goal**: Restore healthy budget quickly

```yaml
actions:
  - archive_unused_patterns: >60 days
  - consolidate_duplicates: >75% similarity
  - path_scope_conversion: all context-specific rules
  - compress_examples: keep only 2 per pattern
  - archive_old_issues: resolved >90 days ago
  - summarize_decisions: deprecated ADRs
  
target_reduction: 25-30%
estimated_time: 60 seconds
```

### Emergency Mode (200+ tokens)
**Goal**: Immediate token budget compliance

```yaml
actions:
  - block_new_additions: true
  - aggressive_archival: >30 days unused
  - consolidate_all_similar: >70% similarity
  - move_to_path_scope: all scoped content
  - compress_all_examples: 1 per pattern only
  - summarize_all_archives: single reference
  
target_reduction: 40%+
estimated_time: 90 seconds
human_review_required: true
```

---

## 📊 Optimization Metrics

### Before/After Tracking
```yaml
cleanup_session:
  timestamp: "2026-01-09T14:30:00Z"
  mode: "normal"
  
  before:
    total_tokens: 165
    patterns: 45
    decisions: 12
    issues: 23
    
  after:
    total_tokens: 142
    patterns: 38 (7 archived)
    decisions: 12
    issues: 18 (5 archived)
    
  improvements:
    token_reduction: 23 (13.9%)
    patterns_consolidated: 3
    examples_compressed: 8
    links_cleaned: 15
    
  quality:
    information_lost: 0%
    readability_improved: true
    cross_references_intact: true
```

---

## 🔄 Automated Triggers

### Scheduled Cleanup
```bash
# Weekly optimization (every Sunday at 23:00)
0 23 * * 0 claude "/cleanup-context --mode=normal"

# Monthly deep cleanup (first day of month)
0 2 1 * * claude "/cleanup-context --mode=aggressive"
```

### Event-Based Triggers
```yaml
triggers:
  - event: "token_budget_warning"
    threshold: 150
    action: "cleanup --mode=normal"
    
  - event: "token_budget_critical"
    threshold: 175
    action: "cleanup --mode=aggressive"
    
  - event: "pattern_addition_blocked"
    threshold: 200
    action: "cleanup --mode=emergency"
    notify: "admin@example.com"
```

---

## 🛡️ Safety Mechanisms

### Backup Before Cleanup
```bash
# Always create backup before pruning
BACKUP_DIR=".claude/backups/cleanup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r .claude/memory-bank "$BACKUP_DIR/"
```

### Validation After Cleanup
```yaml
validation_checks:
  - verify_no_broken_links: true
  - check_pattern_completeness: true
  - validate_markdown_syntax: true
  - ensure_minimum_patterns: 10
  - confirm_no_data_corruption: true
```

### Rollback Capability
```bash
# If cleanup causes issues, rollback
claude "/rollback-cleanup --backup-id=cleanup-20260109-143000"

# Restores memory bank to pre-cleanup state
```

---

## 💡 Optimization Best Practices

### Do's ✅
- Run normal cleanup weekly
- Review aggressive cleanup results
- Keep at least 10 core patterns
- Preserve all historical decisions
- Archive rather than delete

### Don'ts ❌
- Don't delete content permanently
- Don't consolidate dissimilar patterns
- Don't remove active troubleshooting
- Don't skip backup step
- Don't run emergency mode without review

---

## 📈 Efficiency Gains

### Expected Improvements
```yaml
after_cleanup:
  response_speed: +15-20%
  pattern_accuracy: maintained or improved
  context_relevance: +25%
  token_utilization: 70-80% (optimal)
  
long_term:
  maintenance_overhead: -30%
  context_quality: +10%
  learning_efficiency: +15%
```

---

## 🔗 Integration with Other Skills

### With Self-Update Skill
- Self-update adds content → Context pruning optimizes it
- Coordination ensures quality while managing budget

### With Memory-Bank-Synchronizer
- Sync discovers patterns → Pruning consolidates them
- Both work together to maintain healthy memory bank

---

## 🚀 Usage Examples

### Example 1: Weekly Optimization
```bash
$ claude "/cleanup-context"

🔍 Analyzing memory bank...
📊 Current usage: 158/200 tokens (79%)

🧹 Cleanup Plan (Normal Mode):
  - Archive 3 unused patterns (>90 days)
  - Consolidate 2 similar patterns
  - Compress 5 patterns with many examples
  - Clean 8 broken links
  
Estimated reduction: 18 tokens (11%)
Proceed? [y/N]: y

✅ Cleanup completed!
📊 New usage: 140/200 tokens (70%)
💾 Backup: .claude/backups/cleanup-20260109-143000/
```

### Example 2: Aggressive Cleanup
```bash
$ claude "/cleanup-context --mode=aggressive"

⚠️  Token budget critical: 182/200 (91%)

🧹 Cleanup Plan (Aggressive Mode):
  - Archive 8 patterns (>60 days unused)
  - Consolidate 4 similar patterns
  - Move 6 patterns to path-scoped rules
  - Compress all examples to max 2
  - Archive 6 old resolved issues
  
Estimated reduction: 47 tokens (26%)
⚠️  Human review recommended

Proceed? [y/N]: y

✅ Cleanup completed!
📊 New usage: 135/200 tokens (68%)
📋 Review report: .claude/logs/cleanup-report-20260109.md
```

---

## 🔄 Skill Evolution

### v1.0.0 (2026-01-09)
- Initial context pruning skill
- Three cleanup modes
- Automated triggers
- Safety mechanisms

### Future Enhancements
- [ ] ML-based pattern similarity detection
- [ ] Predictive cleanup scheduling
- [ ] User preference learning
- [ ] Cross-project optimization insights

---

**Skill Status**: ✅ Active | 🔥 Hot-Reload Enabled | 🛡️ Safety Mechanisms Active
