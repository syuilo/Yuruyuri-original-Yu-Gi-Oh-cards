--杉浦綾乃
function c1100.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1100, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1100.e1condition)
	c:RegisterEffect(e1)

	-- atkup
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(1100, 1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c1100.e2condition)
	e2:SetCost(c1100.e2cost)
	e2:SetOperation(c1100.e2operation)
	c:RegisterEffect(e2)

end

-- 京子フィルター
function c1100.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつ京子(=1030)か
	return c:IsFaceup() and c:IsCode(1030)
end

function c1100.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1100.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

function c1100.e2condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a:GetControler()==tp and a:IsSetCard(0x186A0) and a:IsRelateToBattle())
		or (d and d:GetControler()==tp and d:IsSetCard(0x186A0) and d:IsRelateToBattle())
end

function c1100.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function c1100.e2operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e1:SetValue(1100)
	a:RegisterEffect(e1)
end
